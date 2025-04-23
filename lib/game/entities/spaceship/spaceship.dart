import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/entities/spaceship/behaviors/behaviors.dart';

/// {@template spaceship}
/// A spaceship that can be controlled with left/right arrow keys.
/// {@endtemplate}
class Spaceship extends PositionedEntity with HasGameReference {
  /// {@macro spaceship}
  Spaceship({
    required super.position,
    this.maxHealth = 3,
  }) : super(
          anchor: Anchor.center,
          size: Vector2(48, 32),
          behaviors: [
            KeyboardMovingBehavior(),
            PropagatingCollisionBehavior(
              RectangleHitbox(
                isSolid: true,
              ),
            ),
          ],
        ) {
    _health = maxHealth;
  }

  /// Creates a test spaceship with custom behaviors.
  @visibleForTesting
  Spaceship.test({
    required super.position,
    super.behaviors,
    this.maxHealth = 3,
  }) : super(size: Vector2(48, 32)) {
    _health = maxHealth;
  }

  /// The maximum health of the spaceship
  final int maxHealth;

  /// Current health of the spaceship
  int _health = 3;

  /// Get the current health
  int get health => _health;

  /// Check if the spaceship is destroyed (health <= 0)
  bool get isDestroyed => _health <= 0;

  /// Decreases the health by the given amount
  void damage([int amount = 1]) {
    if (!isDestroyed) {
      _health -= amount;
      if (_health < 0) _health = 0;
    }
  }

  /// Resets the health to maxHealth
  void resetHealth() {
    _health = maxHealth;
  }

  @override
  Future<void> onLoad() async {
    await add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      ),
    );

    // Add a small cockpit to make it look like a spaceship
    await add(
      RectangleComponent(
        size: Vector2(16, 10),
        position: Vector2(16, 0),
        paint: Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill,
      ),
    );
  }
}
