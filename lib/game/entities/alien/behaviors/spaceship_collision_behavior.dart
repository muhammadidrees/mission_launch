import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/game.dart';

/// {@template spaceship_collision_behavior}
/// A behavior that handles collisions with a spaceship.
/// {@endtemplate}
class SpaceshipCollisionBehavior extends CollisionBehavior<Spaceship, Alien>
    with HasGameReference<MissionLaunch> {
  /// {@macro spaceship_collision_behavior}
  SpaceshipCollisionBehavior({
    this.onSpaceshipCollision,
  });

  /// Called when a collision with a spaceship occurs.
  final void Function(Spaceship spaceship)? onSpaceshipCollision;

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Spaceship other) {
    super.onCollisionStart(intersectionPoints, other);

    // Flash the alien to red to indicate collision
    final originalColor = parent.firstChild<RectangleComponent>()?.paint.color;
    if (originalColor != null) {
      parent.firstChild<RectangleComponent>()?.paint.color = Colors.red;

      // Reset color after a short delay
      parent.add(
        TimerComponent(
          period: 0.2,
          removeOnFinish: true,
          onTick: () {
            parent.firstChild<RectangleComponent>()?.paint.color =
                originalColor;
          },
        ),
      );
    }

    // Play collision sound
    game.effectPlayer.play(AssetSource('audio/effect.mp3'));

    // Call optional callback
    onSpaceshipCollision?.call(other);
  }
}
