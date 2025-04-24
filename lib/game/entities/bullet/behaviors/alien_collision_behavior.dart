import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/entities/bullet/bullet.dart';
import 'package:mission_launch/game/game.dart';

/// {@template alien_collision_behavior}
/// A behavior that handles collisions between bullets and aliens.
/// {@endtemplate}
class AlienCollisionBehavior extends CollisionBehavior<Alien, Bullet>
    with HasGameReference<MissionLaunch> {
  /// {@macro alien_collision_behavior}
  AlienCollisionBehavior();

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Alien other) {
    super.onCollisionStart(intersectionPoints, other);

    // Play hit sound
    game.effectPlayer.play(AssetSource('audio/effect.mp3'));

    // Remove both the bullet and the alien
    parent.removeFromParent();
    other.removeFromParent();

    // Increment score or add other game logic here
    game.counter++;
  }
}
