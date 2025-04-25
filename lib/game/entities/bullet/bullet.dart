import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/entities/bullet/behaviors/behaviors.dart';

/// {@template bullet}
/// A bullet fired by the player's spaceship.
/// {@endtemplate}
class Bullet extends PositionedEntity with HasGameReference {
  /// {@macro bullet}
  Bullet({
    required super.position,
  }) : super(
          anchor: Anchor.center,
          size: Vector2(4, 12),
          behaviors: [
            BulletMovingBehavior(),
            PropagatingCollisionBehavior(
              RectangleHitbox(
                isSolid: true,
              ),
            ),
          ],
        );

  /// Creates a test bullet with custom behaviors.
  @visibleForTesting
  Bullet.test({
    required super.position,
    super.behaviors,
  }) : super(size: Vector2(4, 12));

  @override
  Future<void> onLoad() async {
    await add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill,
      ),
    );
  }
}
