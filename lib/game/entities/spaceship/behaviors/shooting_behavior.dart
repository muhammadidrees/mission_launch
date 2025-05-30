import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/services.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/entities/bullet/bullet.dart';
import 'package:mission_launch/game/entities/spaceship/spaceship.dart';
import 'package:mission_launch/game/mission_launch.dart';

/// {@template shooting_behavior}
/// A behavior that allows the spaceship to shoot bullets.
/// {@endtemplate}
class ShootingBehavior extends Behavior<Spaceship>
    with KeyboardHandler, HasGameReference<MissionLaunch> {
  /// {@macro shooting_behavior}
  ShootingBehavior({
    this.shootKey = LogicalKeyboardKey.space,
  });

  /// The key that triggers shooting.
  final LogicalKeyboardKey shootKey;

  /// Whether the spaceship is currently in cooldown.
  bool _canShoot = true;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent &&
        event.logicalKey == shootKey &&
        _canShoot &&
        !parent.isDestroyed) {
      _shoot();
      return true;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void _shoot() {
    // Create a bullet at the spaceship's position
    final bullet = Bullet(
      position:
          Vector2(parent.position.x, parent.position.y - parent.size.y / 2),
    );

    // Add the bullet to the game world
    parent.parent?.add(bullet);

    // Play shooting sound
    AudioManager.instance.playSpaceshipShoot();

    // Start cooldown
    _canShoot = false;

    // Add a timer to reset the cooldown
    parent.add(
      TimerComponent(
        period: parent.cooldown,
        removeOnFinish: true,
        onTick: () {
          _canShoot = true;
        },
      ),
    );
  }
}
