import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/entities/bullet/bullet.dart';

/// {@template bullet_moving_behavior}
/// A behavior that makes the bullet move upward.
/// {@endtemplate}
class BulletMovingBehavior extends Behavior<Bullet> with HasGameReference {
  /// {@macro bullet_moving_behavior}
  BulletMovingBehavior({
    this.speed = 300,
  });

  /// The speed of the bullet in pixels per second.
  final double speed;

  @override
  void update(double dt) {
    parent.position.y -= speed * dt;

    // Remove the bullet when it goes off screen
    if (parent.position.y < -parent.size.y) {
      parent.removeFromParent();
    }
  }
}
