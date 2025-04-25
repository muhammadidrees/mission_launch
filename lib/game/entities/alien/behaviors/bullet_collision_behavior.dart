import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/game.dart';

/// {@template bullet_collision_behavior}
/// A behavior that handles collisions between aliens and bullets.
/// {@endtemplate}
class BulletCollisionBehavior extends CollisionBehavior<Bullet, Alien>
    with HasGameReference<MissionLaunch> {
  /// {@macro bullet_collision_behavior}
  BulletCollisionBehavior();

  /// Whether the alien is currently in a collision cooldown
  bool _inCooldown = false;

  /// Cooldown duration in seconds to prevent multiple rapid collisions
  static const collisionCooldown = 0.1;

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Bullet other) {
    super.onCollisionStart(intersectionPoints, other);

    // Skip if in cooldown or alien is already destroyed
    if (_inCooldown || parent.isDestroyed) return;

    // Apply damage to the alien
    parent.takeDamage();

    // Remove the bullet
    other.removeFromParent();

    // Play bullet impact sound
    game.effectPlayer.play(AssetSource('audio/effect.mp3'));

    // Start cooldown to prevent multiple rapid collisions
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
