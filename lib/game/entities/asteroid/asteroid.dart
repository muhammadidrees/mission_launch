import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/bloc/game_bloc.dart';
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

  ui.Image getAsset(FlameGame<World> game) {
    switch (this) {
      case AsteroidType.small:
        return game.images.fromCache(Assets.images.asteroid1.path);
      case AsteroidType.medium:
        return game.images.fromCache(Assets.images.asteroid2.path);
      case AsteroidType.large:
        return game.images.fromCache(Assets.images.asteroid3.path);
    }
  }
}

/// {@template asteroid}
/// An asteroid that floats across the screen and can collide
/// with spaceships and bullets.
/// {@endtemplate}
class Asteroid extends PositionedEntity
    with
        HasGameReference<MissionLaunch>,
        FlameBlocListenable<GameBloc, GameState> {
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
    _maxHealth = _type.health;
    _health = _maxHealth;
    size = Vector2.all(30 * _type.size);
    _speedMultiplier = _type.speed;
  }

  /// Base speed of the asteroid in pixels per second
  final double baseSpeed;

  /// Whether the asteroid should target the spaceship
  final bool targetSpaceship;

  /// Rotation speed of the asteroid
  final double rotationSpeed;

  /// The type of asteroid
  late final AsteroidType _type;

  /// Maximum health of the asteroid
  late final int _maxHealth;

  /// Current health of the asteroid
  late int _health;

  /// Speed multiplier based on asteroid type
  late double _speedMultiplier;

  /// Reference to the asteroid sprite
  SpriteComponent? _asteroidSprite;

  /// List of crack components showing damage
  final List<Component> _cracks = [];

  /// Get the effective speed of this asteroid
  double get speed => baseSpeed * _speedMultiplier;

  /// Get the damage this asteroid deals on collision
  int get damage => _type.damage;

  /// Check if the asteroid is destroyed
  bool get isDestroyed => _health <= 0;

  /// Reduce health by the given amount
  void takeDamage([int amount = 1]) {
    final oldHealth = _health;
    _health -= amount;

    // Add cracks if damaged but not destroyed
    if (_health > 0 && oldHealth > _health) {
      _showDamage();
    }

    // Show explosion animation and remove if health reaches 0
    if (_health <= 0) {
      _explode();
    }
  }

  @override
  void onNewState(GameState state) {
    super.onNewState(state);

    if (state.isGameOver) {
      // Remove the drone when the game is over
      removeFromParent();
    }
    if (state.missionComplete) {
      // Remove the drone when the mission is complete
      takeDamage(100);
    }
  }

  /// Add visual damage effects to the asteroid
  void _showDamage() {
    // Clear previous cracks
    for (final crack in _cracks) {
      crack.removeFromParent();
    }
    _cracks.clear();

    // Calculate damage percentage
    final damagePercent = (_maxHealth - _health) / _maxHealth;

    // Adjust the color to show damage
    if (_asteroidSprite != null) {
      _asteroidSprite!.paint.color = Color.lerp(
        Colors.black,
        Colors.red.withOpacity(0.8),
        damagePercent,
      )!;
    }
  }

  /// Show explosion animation and then remove the asteroid
  void _explode() {
    // Get the position and size for the explosion
    final explosionPosition = position.clone();
    final explosionSize = size.clone() * 1.5;

    // Create explosion animation
    final explosion = SpriteAnimationComponent(
      animation: SpriteAnimation.fromFrameData(
        game.images.fromCache(Assets.images.explode.path),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(40),
          loop: false,
        ),
      ),
      position: explosionPosition,
      size: explosionSize,
      anchor: Anchor.center,
      removeOnFinish: true,
    );

    // Add the explosion to the game
    game.add(explosion);

    // Play explosion sound
    AudioManager.instance.playAsteroidExplode();

    // Remove the asteroid
    removeFromParent();
  }

  @override
  Future<void> onLoad() async {
    _asteroidSprite = SpriteComponent.fromImage(
      _type.getAsset(game),
      size: size,
    );

    await add(_asteroidSprite!);

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
