import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/entities/asteroid/behaviors/behaviors.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// Defines the type of asteroid with its properties
enum AsteroidType {
  small(
    size: 3,
    speed: 1.5,
    health: 1,
    damage: 1,
  ),
  medium(
    size: 3.5,
    speed: 1,
    health: 2,
    damage: 2,
  ),
  large(
    size: 4,
    speed: 0.6,
    health: 3,
    damage: 3,
  );

  const AsteroidType({
    required this.size,
    required this.speed,
    required this.health,
    required this.damage,
  });

  final double size;
  final double speed;
  final int health;
  final int damage;

  String get asset {
    switch (this) {
      case AsteroidType.small:
        return Assets.images.asteroid1.path;
      case AsteroidType.medium:
        return Assets.images.asteroid2.path;
      case AsteroidType.large:
        return Assets.images.asteroid3.path;
    }
  }
}

/// {@template asteroid}
/// An asteroid that floats across the screen and can collide
/// with spaceships and bullets.
/// {@endtemplate}
class Asteroid extends PositionedEntity with HasGameReference<MissionLaunch> {
  /// {@macro asteroid}
  Asteroid({
    required super.position,
    AsteroidType? type,
    this.baseSpeed = 100,
    this.targetSpaceship = false,
    Vector2? direction,
    this.rotationSpeed = 0.5,
  }) : super(
          anchor: Anchor.center,
          behaviors: [
            PropagatingCollisionBehavior(
              CircleHitbox(
                isSolid: true,
              ),
            ),
            AsteroidMovingBehavior(
              targetSpaceship: targetSpaceship,
              direction: direction,
            ),
            BulletCollisionBehavior(),
            SpaceshipCollisionBehavior(),
          ],
        ) {
    // Randomly select an asteroid type if not specified
    _type = type ??
        AsteroidType.values[Random().nextInt(AsteroidType.values.length)];

    // Set up asteroid properties based on type
    _health = _type.health;
    size = Vector2.all(30 * _type.size);
    _speedMultiplier = _type.speed;
  }

  /// Creates a test asteroid with custom behaviors.
  @visibleForTesting
  Asteroid.test({
    required super.position,
    super.behaviors,
    this.baseSpeed = 100,
    this.targetSpaceship = false,
    this.rotationSpeed = 0.5,
    AsteroidType? type,
  }) : super(size: Vector2.all(30)) {
    _type = type ?? AsteroidType.small;
    _health = _type.health;
  }

  /// Base speed of the asteroid in pixels per second
  final double baseSpeed;

  /// Whether the asteroid should target the spaceship
  final bool targetSpaceship;

  /// Rotation speed of the asteroid
  final double rotationSpeed;

  /// The type of asteroid
  late final AsteroidType _type;

  /// Current health of the asteroid
  late int _health;

  /// Speed multiplier based on asteroid type
  late double _speedMultiplier;

  /// Get the effective speed of this asteroid
  double get speed => baseSpeed * _speedMultiplier;

  /// Get the damage this asteroid deals on collision
  int get damage => _type.damage;

  /// Check if the asteroid is destroyed
  bool get isDestroyed => _health <= 0;

  /// Reduce health by the given amount
  void takeDamage([int amount = 1]) {
    _health -= amount;

    // Remove if health reaches 0
    if (_health <= 0) {
      removeFromParent();
    }
  }

  @override
  Future<void> onLoad() async {
    await add(
      SpriteComponent(
        sprite: await game.loadSprite(_type.asset),
        size: size,
      ),
    );

    // Start with a random rotation
    angle = Random().nextDouble() * 2 * pi;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Rotate the asteroid
    angle += rotationSpeed * dt;
  }
}
