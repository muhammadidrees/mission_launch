import 'dart:math';
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
  ),
  large(
    size: 1.5,
    health: 4,
    fireRate: 1.5,
    damage: 2,
    frameCount: 4,
  );

  const DroneType({
    required this.size,
    required this.health,
    required this.fireRate,
    required this.damage,
    required this.frameCount,
  });

  final double size;
  final int health;
  final double fireRate;
  final int damage;
  final int frameCount;
}

/// {@template drone}
/// An enemy drone that stays in one position and shoots bullets.
/// {@endtemplate}
class Drone extends PositionedEntity with HasGameReference<MissionLaunch> {
  /// {@macro drone}
  Drone({
    required super.position,
    DroneType? type,
  }) : super(
          scale: Vector2.all(2),
          anchor: Anchor.center,
          behaviors: [
            PropagatingCollisionBehavior(
              CircleHitbox(
                isSolid: true,
              ),
            ),
            DroneShootingBehavior(),
            BulletCollisionBehavior(),
            AsteroidCollisionBehavior(),
          ],
        ) {
    // Set type or choose random
    _type = type ?? DroneType.values[Random().nextInt(DroneType.values.length)];

    // Initialize properties based on type
    _health = _type.health;
    size = Vector2(32, 32) * _type.size;
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

    // Remove if health reaches 0
    if (_health <= 0) {
      removeFromParent();
      // Add explosion effect or sound here
      game.counter += 2; // More points than regular aliens
    }
  }

  @override
  Future<void> onLoad() async {
    // Load the sprite sheet animation
    final animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.drone.path),
      SpriteAnimationData.sequenced(
        amount: _type.frameCount,
        stepTime: 0.15,
        textureSize: Vector2(56, 48),
      ),
    );

    final animationComponent = SpriteAnimationComponent(
      animation: animation,
      size: size,
    );

    await add(animationComponent);
  }
}
