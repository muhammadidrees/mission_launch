import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/game.dart';

/// {@template asteroid_moving_behavior}
/// A behavior that makes the asteroid move in a straight line.
/// {@endtemplate}
class AsteroidMovingBehavior extends Behavior<Asteroid>
    with HasGameReference<MissionLaunch> {
  /// {@macro asteroid_moving_behavior}
  AsteroidMovingBehavior({
    this.targetSpaceship = false,
    Vector2? direction,
  }) : _direction = direction?.normalized();

  /// Whether the asteroid should target the spaceship
  final bool targetSpaceship;

  /// Direction vector of the asteroid
  Vector2? _direction;

  @override
  void onLoad() {
    if (_direction == null) {
      if (targetSpaceship) {
        _findSpaceshipDirection();
      } else {
        _setRandomDirection();
      }
    }
  }

  @override
  void update(double dt) {
    // If we're targeting the spaceship but don't have a direction yet
    // (spaceship might not have been available at onLoad)
    if (targetSpaceship && _direction == null) {
      _findSpaceshipDirection();
      if (_direction == null) return; // Still no spaceship found
    }

    // Move the asteroid in the set direction
    final distance = parent.speed * dt;
    parent.position.add(_direction! * distance);

    // Remove if the asteroid is off screen (with a margin)
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;
    final margin = parent.size.x * 2;

    if (parent.position.x < -margin ||
        parent.position.x > screenWidth + margin ||
        parent.position.y < -margin ||
        parent.position.y > screenHeight + margin) {
      parent.removeFromParent();
    }
  }

  void _setRandomDirection() {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    _direction = Vector2(cos(angle), sin(angle));
  }

  void _findSpaceshipDirection() {
    // Try to find the spaceship
    final spaceship = game.children.whereType<Spaceship>().firstOrNull;

    if (spaceship != null) {
      // Calculate direction to the spaceship
      _direction = (spaceship.position - parent.position).normalized();
    } else {
      // If no spaceship is found, use a random direction
      _setRandomDirection();
    }
  }
}
