import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/entities/alien/behaviors/behaviors.dart';

/// {@template alien}
/// An alien that moves autonomously across the screen.
/// {@endtemplate}
class Alien extends PositionedEntity with HasGameReference {
  /// {@macro alien}
  Alien({
    required super.position,
  }) : super(
          anchor: Anchor.center,
          size: Vector2(40, 40),
          behaviors: [
            AutoMovingBehavior(),
            PropagatingCollisionBehavior(
              RectangleHitbox(
                isSolid: true,
              ),
            ),
            SpaceshipCollisionBehavior(),
          ],
        );

  /// Creates a test alien with custom behaviors.
  @visibleForTesting
  Alien.test({
    required super.position,
    super.behaviors,
  }) : super(size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    await add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill,
      ),
    );

    // Add alien-like features
    await add(
      CircleComponent(
        radius: 8,
        position: Vector2(12, 10),
        paint: Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill,
      ),
    );

    await add(
      CircleComponent(
        radius: 8,
        position: Vector2(28, 10),
        paint: Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill,
      ),
    );

    await add(
      RectangleComponent(
        size: Vector2(20, 5),
        position: Vector2(10, 30),
        paint: Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill,
      ),
    );
  }
}