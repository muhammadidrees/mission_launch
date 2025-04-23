import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/game.dart';

/// {@template auto_moving_behavior}
/// A behavior that makes the alien move automatically in various patterns.
/// {@endtemplate}
class AutoMovingBehavior extends Behavior<Alien>
    with HasGameReference<MissionLaunch> {
  /// {@macro auto_moving_behavior}
  AutoMovingBehavior({
    this.speed = 100,
    this.directionChangeInterval = 2.0,
  });

  /// The speed at which the alien moves.
  final double speed;

  /// How often the alien changes direction (in seconds)
  final double directionChangeInterval;

  /// The movement vector
  final Vector2 _velocity = Vector2.zero();

  /// Time tracker for direction changes
  double _timeSinceDirectionChange = 0;

  /// Random generator for movement
  final Random _random = Random();

  @override
  void onMount() {
    super.onMount();
    _changeDirection();
  }

  @override
  void update(double dt) {
    _timeSinceDirectionChange += dt;

    // Change direction periodically
    if (_timeSinceDirectionChange >= directionChangeInterval) {
      _changeDirection();
      _timeSinceDirectionChange = 0;
    }

    // Move the alien
    parent.position.add(_velocity * dt);

    // Bounce off screen edges
    _handleScreenBounds();
  }

  /// Changes the alien's movement direction randomly
  void _changeDirection() {
    // Generate random values between -1 and 1
    final dx = (_random.nextDouble() * 2) - 1;
    final dy = (_random.nextDouble() * 2) - 1;

    // Set the velocity vector and normalize it to maintain consistent speed
    _velocity
      ..setValues(dx, dy)
      ..normalize()
      ..scale(speed);
  }

  /// Handles collisions with screen edges
  void _handleScreenBounds() {
    final pos = parent.position;
    final size = parent.size;
    final screenSize = game.size;

    // Left and right bounds
    if (pos.x - size.x / 2 < 0) {
      pos.x = size.x / 2;
      _velocity.x = _velocity.x.abs(); // Reverse direction
    } else if (pos.x + size.x / 2 > screenSize.x) {
      pos.x = screenSize.x - size.x / 2;
      _velocity.x = -_velocity.x.abs(); // Reverse direction
    }

    // Top and bottom bounds
    if (pos.y - size.y / 2 < 0) {
      pos.y = size.y / 2;
      _velocity.y = _velocity.y.abs(); // Reverse direction
    } else if (pos.y + size.y / 2 > screenSize.y) {
      pos.y = screenSize.y - size.y / 2;
      _velocity.y = -_velocity.y.abs(); // Reverse direction
    }
  }
}
