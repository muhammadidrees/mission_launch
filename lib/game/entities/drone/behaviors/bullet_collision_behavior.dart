import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
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

    // Play hit sound
    game.effectPlayer.play(AssetSource('audio/effect.mp3'));

    // Remove the bullet
    other.removeFromParent();

    // Damage the drone
    parent.takeDamage();
  }
}
