import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/game.dart';

/// Defines the movement states of the drone
enum DroneMovementState {
  /// Flying in from an edge of the screen
  flyingIn,

  /// Hovering in final position
  hovering,
}

/// {@template drone_moving_behavior}
/// A behavior that controls the drone's movement pattern.
/// The drone will:
/// 1. Fly in from an edge of the screen
/// 2. Hover in a fixed position once it reaches its destination
/// {@endtemplate}
class DroneMovingBehavior extends Behavior<Drone>
    with HasGameReference<MissionLaunch> {
  /// {@macro drone_moving_behavior}
  DroneMovingBehavior({
    required this.targetPosition,
    this.flyInSpeed = 300,
  });

  /// The position the drone will fly to and hover at
  final Vector2 targetPosition;

  /// Speed at which the drone flies in
  final double flyInSpeed;

  /// Current state of movement
  DroneMovementState _state = DroneMovementState.flyingIn;

  /// Timer for hovering oscillation
  double _hoverTimer = 0;

  @override
  void update(double dt) {
    if (parent.isDestroyed) return;

    switch (_state) {
      case DroneMovementState.flyingIn:
        _handleFlyingIn(dt);
      case DroneMovementState.hovering:
        _handleHovering(dt);
    }
  }

  void _handleFlyingIn(double dt) {
    // Calculate direction vector to target position
    final direction = (targetPosition - parent.position).normalized();

    // Move towards target position
    parent.position += direction * flyInSpeed * dt;

    // Check if we've reached the target position (within a small threshold)
    if (parent.position.distanceTo(targetPosition) < 10) {
      parent.position = targetPosition.clone(); // Snap to exact position
      _state = DroneMovementState.hovering;
    }
  }

  void _handleHovering(double dt) {
    _hoverTimer += dt;

    // Small oscillation when hovering to make it look more natural
    final offsetX = sin(_hoverTimer * 1.5) * 0.7;
    final offsetY = cos(_hoverTimer * 1.2) * 0.5;

    parent.position = Vector2(
      targetPosition.x + offsetX,
      targetPosition.y + offsetY,
    );
  }

  /// Return the current movement state
  DroneMovementState get currentState => _state;
}
