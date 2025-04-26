import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/entities/asteroid/behaviors/asteroid_moving_behavior.dart';
import 'package:mission_launch/game/game.dart';

/// {@template asteroid_collision_behavior}
/// A behavior that handles collisions between aliens and asteroids.
/// {@endtemplate}
class AsteroidCollisionBehavior extends CollisionBehavior<Asteroid, Alien>
    with HasGameReference<MissionLaunch> {
  /// {@macro asteroid_collision_behavior}
  AsteroidCollisionBehavior();

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Asteroid other) {
    super.onCollisionStart(intersectionPoints, other);

    // Find the asteroid's movement behavior
    final movingBehavior =
        other.children.whereType<AsteroidMovingBehavior>().firstOrNull;

    if (movingBehavior != null) {
      // Create a bounce effect - reflect the asteroid's direction
      final collisionNormal = (other.position - parent.position).normalized();

      // Set new direction for asteroid (bounce effect)
      movingBehavior.setDirection(collisionNormal);
    }

    // Damage both the alien and the asteroid
    parent.takeDamage();
    other.takeDamage();

    // Play collision sound
    AudioManager.instance.playAsteroidHit();
  }
}
