import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/game.dart';

/// Defines the movement states of the alien
enum AlienMovementState {
  /// Flying in from the side
  flyingIn,

  /// Hovering in place
  hovering,

  /// Moving to the left
  movingLeft,

  /// Moving to the right
  movingRight,
}

/// {@template alien_moving_behavior}
/// A behavior that controls the alien's movement pattern.
/// The alien will:
/// 1. Fly in from the side of the screen
/// 2. Hover for a few seconds
/// 3. Move left while shooting
/// 4. Move right while shooting
/// 5. Repeat steps 2-4
/// {@endtemplate}
class AlienMovingBehavior extends Behavior<Alien>
    with HasGameReference<MissionLaunch> {
  /// {@macro alien_moving_behavior}
  AlienMovingBehavior({
    this.hoverDuration = 1.5,
    this.moveDuration = 2.0,
  });

  /// Duration of hovering state in seconds
  final double hoverDuration;

  /// Duration of movement phases in seconds
  final double moveDuration;

  /// Current state of movement
  AlienMovementState _state = AlienMovementState.flyingIn;

  /// Timer to track state transitions
  double _stateTimer = 0;

  /// Original position for the alien to return to after movements
  late Vector2 _centralPosition;

  /// Random number generator
  final _random = Random();

  /// Movement amplitude (how far the alien moves side to side)
  double _movementAmplitude = 0;

  @override
  void onLoad() {
    super.onLoad();

    // Set movement amplitude based on alien size and screen width
    _movementAmplitude = game.size.x * 0.2;

    // Store the central position the alien will hover around
    _centralPosition = Vector2(
      game.size.x *
          (0.3 + _random.nextDouble() * 0.4), // 30-70% of screen width
      parent.position.y,
    );
  }

  @override
  void update(double dt) {
    if (parent.isDestroyed) return;

    _stateTimer += dt;

    switch (_state) {
      case AlienMovementState.flyingIn:
        _handleFlyingIn(dt);
      case AlienMovementState.hovering:
        _handleHovering(dt);
      case AlienMovementState.movingLeft:
        _handleMovingLeft(dt);
      case AlienMovementState.movingRight:
        _handleMovingRight(dt);
    }
  }

  void _handleFlyingIn(double dt) {
    // Move toward the central position
    final direction = (_centralPosition - parent.position).normalized();
    parent.position += direction * parent.movementSpeed * dt;

    // Check if we're close enough to the central position
    if (parent.position.distanceTo(_centralPosition) < 10) {
      _transitionToState(AlienMovementState.hovering);
    }
  }

  void _handleHovering(double dt) {
    // Small vertical oscillation while hovering
    parent.position.y += sin(_stateTimer * 3) * 0.5;

    // Transition to moving left after hover duration
    if (_stateTimer >= hoverDuration) {
      _transitionToState(AlienMovementState.movingLeft);
    }
  }

  void _handleMovingLeft(double dt) {
    // Move left
    parent.position.x -= parent.movementSpeed * 0.7 * dt;

    // Ensure we don't move too far left
    final minX = _centralPosition.x - _movementAmplitude;
    if (parent.position.x <= minX || _stateTimer >= moveDuration) {
      _transitionToState(AlienMovementState.movingRight);
    }
  }

  void _handleMovingRight(double dt) {
    // Move right
    parent.position.x += parent.movementSpeed * 0.7 * dt;

    // Ensure we don't move too far right
    final maxX = _centralPosition.x + _movementAmplitude;
    if (parent.position.x >= maxX || _stateTimer >= moveDuration) {
      _transitionToState(AlienMovementState.hovering);
    }
  }

  void _transitionToState(AlienMovementState newState) {
    _state = newState;
    _stateTimer = 0;
  }

  /// Get the current movement state - used by other behaviors
  AlienMovementState get currentState => _state;
}
