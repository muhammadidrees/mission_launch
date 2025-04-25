import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/services.dart';
import 'package:mission_launch/game/game.dart';

/// {@template keyboard_moving_behavior}
/// A behavior that makes the spaceship move left and right
/// based on keyboard input.
/// {@endtemplate}
class KeyboardMovingBehavior extends Behavior<Spaceship>
    with KeyboardHandler, HasGameReference<MissionLaunch> {
  /// {@macro keyboard_moving_behavior}
  KeyboardMovingBehavior({
    this.speed = 200,
    this.leftKey = LogicalKeyboardKey.arrowLeft,
    this.rightKey = LogicalKeyboardKey.arrowRight,
  });

  /// The speed at which the spaceship moves.
  final double speed;

  /// The left movement key.
  final LogicalKeyboardKey leftKey;

  /// The right movement key.
  final LogicalKeyboardKey rightKey;

  /// The movement direction.
  /// -1 is left, 0 is stationary, 1 is right.
  double _movement = 0;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Update movement direction
    if (keysPressed.contains(leftKey)) {
      _movement = -1;
      parent.setState(SpaceshipState.left); // Change animation to left
    } else if (keysPressed.contains(rightKey)) {
      _movement = 1;
      parent.setState(SpaceshipState.right); // Change animation to right
    } else {
      _movement = 0;
      parent.setState(SpaceshipState.idle); // Change animation to idle
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    parent.position.x += _movement * speed * dt;

    // Clamp position to screen bounds
    parent.position.x = parent.position.x.clamp(
      parent.size.x / 2,
      game.size.x - parent.size.x / 2,
    );
  }
}
