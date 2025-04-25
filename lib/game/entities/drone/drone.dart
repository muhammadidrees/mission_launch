import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/entities/drone/behaviors/behaviors.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// Defines the type of drone with its properties
enum DroneType {
  small(
    size: 1,
    health: 2,
    fireRate: 2,
    damage: 1,
    frameCount: 4,
    flyInSpeed: 300,
  ),
  large(
    size: 1.5,
    health: 4,
    fireRate: 1.5,
    damage: 2,
    frameCount: 4,
    flyInSpeed: 250,
  );

  const DroneType({
    required this.size,
    required this.health,
    required this.fireRate,
    required this.damage,
    required this.frameCount,
    required this.flyInSpeed,
  });

  final double size;
  final int health;
  final double fireRate;
  final int damage;
  final int frameCount;
  final double flyInSpeed;
}

/// {@template drone}
/// An enemy drone that flies in from an edge, hovers in place, and shoots bullets.
/// {@endtemplate}
class Drone extends PositionedEntity with HasGameReference<MissionLaunch> {
  /// {@macro drone}
  Drone({
    required super.position,
    required Vector2 targetPosition,
    DroneType? type,
  }) : super(
          scale: Vector2.all(1.4),
          anchor: Anchor.center,
          behaviors: [
            PropagatingCollisionBehavior(
              CircleHitbox(
                isSolid: true,
              ),
            ),
            BulletCollisionBehavior(),
            AsteroidCollisionBehavior(),
          ],
        ) {
    // Set type or choose random
    _type = type ?? DroneType.values[Random().nextInt(DroneType.values.length)];

    // Initialize properties based on type
    _health = _type.health;
    size = Vector2(56, 48) * _type.size;

    // Add movement behavior (fly in, then hover)
    add(DroneMovingBehavior(
      targetPosition: targetPosition,
      flyInSpeed: _type.flyInSpeed,
    ));

    // Add shooting behavior
    // Only shoot when in hovering state to avoid shooting while flying in
    add(DroneShootingBehavior());
  }

  /// The type of drone
  late final DroneType _type;

  /// Current health of the drone
  late int _health;

  /// Whether this drone is destroyed
  bool get isDestroyed => _health <= 0;

  /// Get the damage this drone deals on collision
  int get damage => _type.damage;

  /// Get the fire rate of this drone
  double get fireRate => _type.fireRate;

  /// Reduce health by the given amount
  void takeDamage([int amount = 1]) {
    _health -= amount;

    // If health reaches 0, create falling drone and remove this one
    if (_health <= 0) {
      // Create a falling drone at this position
      // using the broken drone animation
      final fallingDrone = FallingDrone(
        position: position.clone(),
        droneType: _type,
        fallSpeed:
            150 + Random().nextDouble() * 100, // Random speed between 150-250
        rotationSpeed:
            (Random().nextDouble() * 4) - 2, // Random rotation between -2 and 2
      );

      parent?.add(fallingDrone);

      // Add score
      game.counter += 2; // More points than regular aliens

      // Play destruction sound
      game.effectPlayer.play(AssetSource('audio/effect.mp3'));

      // Remove the original drone
      removeFromParent();
    }
  }

  @override
  Future<void> onLoad() async {
    // Load the sprite sheet animation
    final animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.drone.path),
      SpriteAnimationData.sequenced(
        amount: _type.frameCount,
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
}
