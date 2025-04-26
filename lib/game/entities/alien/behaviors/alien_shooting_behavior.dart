import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/entities/alien/behaviors/alien_moving_behavior.dart';
import 'package:mission_launch/game/game.dart';

/// {@template alien_shooting_behavior}
/// A behavior that makes the alien shoot bullets when moving.
/// Shoots 3 bullets when moving left and 3 bullets when moving right.
/// {@endtemplate}
class AlienShootingBehavior extends Behavior<Alien>
    with HasGameReference<MissionLaunch> {
  /// {@macro alien_shooting_behavior}
  AlienShootingBehavior();

  /// Timer to track when to shoot next
  double _timeUntilNextShot = 0;

  /// Random number generator
  final _random = Random();

  /// Count of bullets shot during the current movement phase
  int _bulletsShotInPhase = 0;

  /// The previous movement state of the alien
  AlienMovementState? _previousState;

  /// Maximum number of bullets to shoot per movement phase
  static const _maxBulletsPerPhase = 3;

  @override
  void onLoad() {
    super.onLoad();
    // Randomize initial shot time
    _timeUntilNextShot = _random.nextDouble() * parent.fireRate;
  }

  @override
  void update(double dt) {
    if (parent.isDestroyed) return;

    // Get the current movement state from the AlienMovingBehavior
    final movingBehavior =
        parent.children.whereType<AlienMovingBehavior>().firstOrNull;
    if (movingBehavior == null) return;

    final currentState = movingBehavior.currentState;

    // Reset bullet count when changing between movement phases
    if (_previousState != currentState) {
      if ((currentState == AlienMovementState.movingLeft ||
              currentState == AlienMovementState.movingRight) &&
          (_previousState != AlienMovementState.movingLeft &&
              _previousState != AlienMovementState.movingRight)) {
        _bulletsShotInPhase = 0;
      }
      _previousState = currentState;
    }

    // Only shoot during movingLeft or movingRight states
    // and only if we haven't shot the max number of bullets yet
    if ((currentState == AlienMovementState.movingLeft ||
            currentState == AlienMovementState.movingRight) &&
        _bulletsShotInPhase < _maxBulletsPerPhase) {
      _timeUntilNextShot -= dt;

      if (_timeUntilNextShot <= 0) {
        _shoot();
        _bulletsShotInPhase++;

        // Set shorter delay between shots in the same burst
        _timeUntilNextShot = parent.fireRate / 3;
      }
    }
  }

  void _shoot() {
    // Create a bullet position at the bottom of the alien
    final bulletPosition = Vector2(
      parent.position.x,
      parent.position.y + parent.size.y / 2,
    );

    // Direction vector for the bullet (downward)
    final direction = Vector2(0, 1);

    // Create and add the bullet
    final bullet = AlienBullet(
      position: bulletPosition,
      direction: direction,
      damage: parent.damage,
    );

    parent.parent?.add(bullet);

    // Play alien shooting sound effect
    AudioManager.instance.playAlienShoot();
  }
}

/// {@template alien_bullet}
/// A bullet fired by enemy aliens.
/// {@endtemplate}
class AlienBullet extends PositionedEntity with HasGameReference {
  /// {@macro alien_bullet}
  AlienBullet({
    required super.position,
    required this.direction,
    this.speed = 250, // Faster than drone bullets
    this.damage = 1,
  }) : super(
          anchor: Anchor.center,
          size: Vector2(5, 10),
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
          ..color = Colors.green
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
    extends CollisionBehavior<Spaceship, AlienBullet>
    with HasGameReference<MissionLaunch> {
  /// {@macro spaceship_collision_behavior}
  SpaceshipCollisionBehavior();

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Spaceship other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other.isDestroyed) return;

    // Damage the spaceship
    other.damage(parent.damage);

    // Play hit sound
    AudioManager.instance.playHit();

    // Remove the bullet
    parent.removeFromParent();
  }
}
