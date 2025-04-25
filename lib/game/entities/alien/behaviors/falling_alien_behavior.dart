import 'package:audioplayers/audioplayers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// {@template falling_alien}
/// A component representing a destroyed alien that falls
/// and can damage the spaceship.
/// {@endtemplate}
class FallingAlien extends PositionedEntity
    with HasGameReference<MissionLaunch> {
  /// {@macro falling_alien}
  FallingAlien({
    required super.position,
    required this.alienType,
    this.fallSpeed = 220,
    this.rotationSpeed = 1.8,
  }) : super(
          scale: Vector2.all(1.5),
          anchor: Anchor.center,
          size: Vector2(56, 48) * alienType.size,
          behaviors: [
            PropagatingCollisionBehavior(
              CircleHitbox(
                isSolid: true,
              ),
            ),
            _SpaceshipCollisionBehavior(),
          ],
        );

  /// The type of alien this was
  final AlienType alienType;

  /// Speed at which the alien falls
  final double fallSpeed;

  /// Speed at which the alien rotates while falling
  final double rotationSpeed;

  @override
  Future<void> onLoad() async {
    // Use the dedicated broken alien animation
    final animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.alienBroken.path),
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.1,
        textureSize: Vector2(54, 36),
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

    // Remove if off the bottom of the screen
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
}

/// A behavior that handles collisions between falling aliens and the spaceship
class _SpaceshipCollisionBehavior
    extends CollisionBehavior<Spaceship, FallingAlien>
    with HasGameReference<MissionLaunch> {
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Spaceship other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other.isDestroyed) return;

    // Damage the spaceship
    other.damage(parent.alienType.damage);

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

    // Remove the falling alien
    parent.removeFromParent();
  }
}
