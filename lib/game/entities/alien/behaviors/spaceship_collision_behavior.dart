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
    this.damageAmount = 1,
    this.collisionCooldown = 1.0,
  });

  /// Called when a collision with a spaceship occurs.
  final void Function(Spaceship spaceship)? onSpaceshipCollision;

  /// Amount of damage to apply to spaceship on collision
  final int damageAmount;

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
    other.damage(damageAmount);

    // Play collision sound
    game.effectPlayer.play(AssetSource('audio/effect.mp3'));

    // Call optional callback
    onSpaceshipCollision?.call(other);

    // Set cooldown
    _inCooldown = true;

    // Reset cooldown after delay
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
