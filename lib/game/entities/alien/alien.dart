import 'dart:developer' as dev;
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/entities/alien/behaviors/behaviors.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// Defines the type of alien with its properties
enum AlienType {
  small(
    size: 1,
    health: 3,
    fireRate: 2.5,
    damage: 1,
    frameCount: 4,
    movementSpeed: 100,
  ),
  large(
    size: 1.5,
    health: 5,
    fireRate: 2,
    damage: 2,
    frameCount: 4,
    movementSpeed: 70,
  );

  const AlienType({
    required this.size,
    required this.health,
    required this.fireRate,
    required this.damage,
    required this.frameCount,
    required this.movementSpeed,
  });

  final double size;
  final int health;
  final double fireRate;
  final int damage;
  final int frameCount;
  final double movementSpeed;
}

/// {@template alien}
/// An enemy alien that moves across the screen and shoots bullets.
/// {@endtemplate}
class Alien extends PositionedEntity
    with
        HasGameReference<MissionLaunch>,
        FlameBlocListenable<GameBloc, GameState> {
  /// {@macro alien}
  Alien({
    required super.position,
    AlienType? type,
  }) : super(
          scale: Vector2.all(1.5),
          anchor: Anchor.center,
          behaviors: [
            PropagatingCollisionBehavior(
              CircleHitbox(
                isSolid: true,
              ),
            ),
            AlienMovingBehavior(),
            AlienShootingBehavior(),
            BulletCollisionBehavior(),
            AsteroidCollisionBehavior(),
            AlienAudioBehavior(),
          ],
        ) {
    // Set type or choose random
    _type = type ?? AlienType.values[Random().nextInt(AlienType.values.length)];

    // Initialize properties based on type
    _health = _type.health;
    size = Vector2(56, 48) * _type.size;
  }

  /// The type of alien
  late final AlienType _type;

  /// Current health of the alien
  late int _health;

  /// Whether this alien is destroyed
  bool get isDestroyed => _health <= 0;

  /// Get the damage this alien deals on collision
  int get damage => _type.damage;

  /// Get the fire rate of this alien
  double get fireRate => _type.fireRate;

  /// Get the movement speed of this alien
  double get movementSpeed => _type.movementSpeed;

  /// Reduce health by the given amount
  void takeDamage([int amount = 1]) {
    _health -= amount;

    // If health reaches 0, create falling alien and remove this one
    if (_health <= 0) {
      // Print debug info
      dev.log('Alien destroyed - playing explosion sound');

      // Create a falling alien at this position
      // using the broken alien animation
      final fallingAlien = FallingAlien(
        position: position.clone(),
        alienType: _type,
        fallSpeed:
            170 + Random().nextDouble() * 100, // Random speed between 170-270
        rotationSpeed:
            (Random().nextDouble() * 4) - 2, // Random rotation between -2 and 2
      );

      parent?.add(fallingAlien);

      // Add score
      game.counter += 3; // More points than regular drones

      // Play explosion sound - ensure it plays before removal
      try {
        // Play with higher volume and ensure it starts
        AudioManager.instance.playEnemyExplode();

        dev.log('Explosion sound should be playing');
      } catch (e) {
        dev.log('Error playing alien explosion sound: $e');
      }

      // Add a slight delay before removing to ensure sound starts playing
      parent?.add(
        TimerComponent(
          period: 0.1,
          removeOnFinish: true,
          onTick: removeFromParent,
        ),
      );
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

  @override
  Future<void> onLoad() async {
    // Load the sprite sheet animation
    final animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.alien.path),
      SpriteAnimationData.sequenced(
        amount: _type.frameCount,
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
}
