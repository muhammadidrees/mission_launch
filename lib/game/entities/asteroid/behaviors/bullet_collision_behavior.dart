import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/entities/bullet/bullet.dart';
import 'package:mission_launch/game/game.dart';

/// {@template bullet_collision_behavior}
/// A behavior that handles collisions between asteroids and bullets.
/// {@endtemplate}
class BulletCollisionBehavior extends CollisionBehavior<Bullet, Asteroid>
    with HasGameReference<MissionLaunch> {
  /// {@macro bullet_collision_behavior}
  BulletCollisionBehavior();

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Bullet other) {
    super.onCollisionStart(intersectionPoints, other);

    // Play hit sound
    game.effectPlayer.play(AssetSource('audio/effect.mp3'));

    // Remove the bullet
    other.removeFromParent();

    // Damage the asteroid
    parent.takeDamage();

    // Add score only if asteroid is destroyed
    if (parent.isDestroyed) {
      game.counter++;
    }
  }
}
