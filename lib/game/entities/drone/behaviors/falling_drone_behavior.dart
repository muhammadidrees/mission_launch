import 'package:audioplayers/audioplayers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// {@template falling_drone}
/// A component representing a destroyed drone that falls
/// and can damage the spaceship.
/// {@endtemplate}
class FallingDrone extends PositionedEntity
    with HasGameReference<MissionLaunch> {
  /// {@macro falling_drone}
  FallingDrone({
    required super.position,
    required this.droneType,
    this.fallSpeed = 200,
    this.rotationSpeed = 1.5,
  }) : super(
          scale: Vector2.all(1.4),
          anchor: Anchor.center,
          size: Vector2(56, 48) * droneType.size,
          behaviors: [
            PropagatingCollisionBehavior(
              CircleHitbox(
                isSolid: true,
              ),
            ),
            _SpaceshipCollisionBehavior(),
          ],
        );

  /// The type of drone this was
  final DroneType droneType;

  /// Speed at which the drone falls
  final double fallSpeed;

  /// Speed at which the drone rotates while falling
  final double rotationSpeed;

  @override
  Future<void> onLoad() async {
    // Use the dedicated broken drone animation
    final animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.droneBroken.path),
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.1,
        textureSize: Vector2(56, 48),
      ),
    );

    await add(
      SpriteAnimationComponent(
        animation: animation,
        size: size,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Fall downward
    position.y += fallSpeed * dt;

    // Rotate while falling
    angle += rotationSpeed * dt;

    // Remove when off screen
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
}

/// {@template spaceship_collision_behavior}
/// A behavior that handles collisions between falling drones and the spaceship.
/// {@endtemplate}
class _SpaceshipCollisionBehavior
    extends CollisionBehavior<Spaceship, FallingDrone>
    with HasGameReference<MissionLaunch> {
  /// {@macro spaceship_collision_behavior}
  _SpaceshipCollisionBehavior();

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Spaceship other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other.isDestroyed) return;

    // Damage the spaceship based on the drone type
    other.damage(parent.droneType.damage);

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

    // Play collision sound
    game.effectPlayer.play(AssetSource('audio/effect.mp3'));

    // Remove the falling drone
    parent.removeFromParent();
  }
}
