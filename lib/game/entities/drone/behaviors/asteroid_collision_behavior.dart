import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/game.dart';

/// {@template asteroid_collision_behavior}
/// A behavior that handles collisions between asteroids and drones.
/// {@endtemplate}
class AsteroidCollisionBehavior extends CollisionBehavior<Asteroid, Drone>
    with HasGameReference<MissionLaunch> {
  /// {@macro asteroid_collision_behavior}
  AsteroidCollisionBehavior();

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Asteroid other) {
    super.onCollisionStart(intersectionPoints, other);

    // Damage both the drone and the asteroid
    parent.takeDamage();
    other.takeDamage();

    // Play collision sound
    game.effectPlayer.play(AssetSource('audio/effect.mp3'));
  }
}
