import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/game.dart';

/// {@template bullet_collision_behavior}
/// A behavior that handles collisions between player bullets and drones.
/// {@endtemplate}
class BulletCollisionBehavior extends CollisionBehavior<Bullet, Drone>
    with HasGameReference<MissionLaunch> {
  /// {@macro bullet_collision_behavior}
  BulletCollisionBehavior();

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Bullet other) {
    super.onCollisionStart(intersectionPoints, other);

    // Damage the drone
    parent.takeDamage();

    // Remove the bullet
    other.removeFromParent();

    // Play hit sound
    AudioManager.instance.playHit();
  }
}
