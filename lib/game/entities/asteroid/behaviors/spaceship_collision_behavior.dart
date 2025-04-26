import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/game.dart';

/// {@template spaceship_collision_behavior}
/// A behavior that handles collisions between asteroids and the spaceship.
/// {@endtemplate}
class SpaceshipCollisionBehavior extends CollisionBehavior<Spaceship, Asteroid>
    with HasGameReference<MissionLaunch> {
  /// {@macro spaceship_collision_behavior}
  SpaceshipCollisionBehavior({
    this.collisionCooldown = 0.5,
  });

  /// Cooldown period between collisions in seconds
  final double collisionCooldown;

  /// Flag to track if in cooldown period
  bool _inCooldown = false;

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Spaceship other) {
    super.onCollisionStart(intersectionPoints, other);

    // Skip if we're in cooldown, if spaceship is already destroyed,
    // or if spaceship is currently invincible
    if (_inCooldown || other.isDestroyed || other.isInvincible) return;

    // Play collision sound
    AudioManager.instance.playAsteroidHit();

    // Damage the spaceship (this also triggers invincibility and blinking)
    other.damage(parent.damage);

    // Remove the asteroid
    parent.removeFromParent();

    // Start cooldown
    _inCooldown = true;
    parent.add(
      TimerComponent(
        period: collisionCooldown,
        removeOnFinish: true,
        onTick: () {
          _inCooldown = false;
        },
      ),
    );
  }
}
