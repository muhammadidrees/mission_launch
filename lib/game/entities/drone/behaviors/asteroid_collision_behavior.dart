import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/entities/asteroid/behaviors/asteroid_moving_behavior.dart';
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

    // Calculate bounce direction for the asteroid
    final bounceDirection = (other.position - parent.position).normalized();

    // Find the asteroid's moving behavior to change its direction
    final movingBehavior =
        other.children.whereType<AsteroidMovingBehavior>().firstOrNull;
    if (movingBehavior != null) {
      // Set new direction for asteroid (bounce effect)
      movingBehavior.setDirection(bounceDirection);
    }

    // Damage both the drone and the asteroid
    parent.takeDamage();
    other.takeDamage();

    // Play collision sound
    game.effectPlayer.play(AssetSource('audio/effect.mp3'));
  }
}
