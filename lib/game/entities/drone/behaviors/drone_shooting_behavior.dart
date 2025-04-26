import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/entities/drone/behaviors/drone_moving_behavior.dart';
import 'package:mission_launch/game/game.dart';

/// {@template drone_shooting_behavior}
/// A behavior that makes the drone shoot bullets periodically.
/// Only shoots when the drone is hovering, not when flying in.
/// {@endtemplate}
class DroneShootingBehavior extends Behavior<Drone>
    with HasGameReference<MissionLaunch> {
  /// {@macro drone_shooting_behavior}
  DroneShootingBehavior();

  /// Timer to track when to shoot next
  double _timeUntilNextShot = 0;

  /// Random number generator
  final _random = Random();

  @override
  void onLoad() {
    super.onLoad();
    // Randomize initial shot time to avoid all drones shooting at once
    _timeUntilNextShot = _random.nextDouble() * parent.fireRate;
  }

  @override
  void update(double dt) {
    if (parent.isDestroyed) return;

    // Only shoot when the drone is hovering, not when flying in
    final movingBehavior =
        parent.children.whereType<DroneMovingBehavior>().firstOrNull;
    if (movingBehavior == null ||
        movingBehavior.currentState != DroneMovementState.hovering) {
      return;
    }

    _timeUntilNextShot -= dt;

    if (_timeUntilNextShot <= 0) {
      _shoot();
      // Reset timer
      _timeUntilNextShot = parent.fireRate;
    }
  }

  void _shoot() {
    // Create two bullets, one from each side of the drone
    final leftBulletPosition = Vector2(
      parent.position.x - parent.size.x / 2,
      parent.position.y,
    );

    final rightBulletPosition = Vector2(
      parent.position.x + parent.size.x / 2,
      parent.position.y,
    );

    // Direction vectors for the bullets (sideways and slightly downward)
    final leftDirection = Vector2(-1, 1).normalized();
    final rightDirection = Vector2(1, 1).normalized();

    // Create and add the bullets
    final leftBullet = DroneBullet(
      position: leftBulletPosition,
      direction: leftDirection,
      damage: parent.damage,
    );

    final rightBullet = DroneBullet(
      position: rightBulletPosition,
      direction: rightDirection,
      damage: parent.damage,
    );

    parent.parent?.add(leftBullet);
    parent.parent?.add(rightBullet);

    // Play sound effect
    AudioManager.instance.playDroneShoot();
  }
}

/// {@template drone_bullet}
/// A bullet fired by enemy drones.
/// {@endtemplate}
class DroneBullet extends PositionedEntity with HasGameReference {
  /// {@macro drone_bullet}
  DroneBullet({
    required super.position,
    required this.direction,
    this.speed = 200,
    this.damage = 1,
  }) : super(
          anchor: Anchor.center,
          size: Vector2(4, 8),
          behaviors: [
            PropagatingCollisionBehavior(
              RectangleHitbox(
                isSolid: true,
              ),
            ),
            SpaceshipCollisionBehavior(),
          ],
        );

  /// Direction vector of the bullet
  final Vector2 direction;

  /// Speed of the bullet in pixels per second
  final double speed;

  /// Damage dealt by this bullet
  final int damage;

  @override
  Future<void> onLoad() async {
    await add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the bullet
    position.add(direction * speed * dt);

    // Remove if off screen
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    if (position.x < -size.x ||
        position.x > screenWidth + size.x ||
        position.y < -size.y ||
        position.y > screenHeight + size.y) {
      removeFromParent();
    }
  }
}

/// {@template spaceship_collision_behavior}
/// A behavior that handles collisions with the spaceship.
/// {@endtemplate}
class SpaceshipCollisionBehavior
    extends CollisionBehavior<Spaceship, DroneBullet>
    with HasGameReference<MissionLaunch> {
  /// {@macro spaceship_collision_behavior}
  SpaceshipCollisionBehavior();

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Spaceship other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other.isDestroyed) return;

    // Damage the spaceship
    other.damage(parent.damage);

    // Play collision sound
    AudioManager.instance.playHit();

    // Remove the bullet
    parent.removeFromParent();
  }
}
