import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';

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

    // Skip if we're in cooldown or if spaceship is already destroyed
    if (_inCooldown || other.isDestroyed) return;

    // Flash the spaceship to red to indicate damage
    final spaceshipComponent = other.firstChild<RectangleComponent>();
    final originalColor = spaceshipComponent?.paint.color;

    if (originalColor != null) {
      spaceshipComponent?.paint.color = Colors.red;

      // Reset color after a short delay
      other.add(
        TimerComponent(
          period: 0.2,
          removeOnFinish: true,
          onTick: () {
            if (!other.isDestroyed) {
              spaceshipComponent?.paint.color = originalColor;
            }
          },
        ),
      );
    }

    // Damage the spaceship
    other.damage(parent.damage);

    // Play collision sound
    game.effectPlayer.play(AssetSource(Assets.audio.asteriodHit));

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
