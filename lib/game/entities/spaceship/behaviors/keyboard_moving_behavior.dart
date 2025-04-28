import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/services.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/game.dart';

/// {@template keyboard_moving_behavior}
/// A behavior that makes the spaceship move left and right
/// based on keyboard input.
/// {@endtemplate}
class KeyboardMovingBehavior extends Behavior<Spaceship>
    with
        KeyboardHandler,
        HasGameReference<MissionLaunch>,
        FlameBlocReader<GameBloc, GameState> {
  /// {@macro keyboard_moving_behavior}
  KeyboardMovingBehavior({
    this.leftKey = LogicalKeyboardKey.arrowLeft,
    this.rightKey = LogicalKeyboardKey.arrowRight,
    this.upKey = LogicalKeyboardKey.arrowUp,
    this.downKey = LogicalKeyboardKey.arrowDown,
  });

  /// The left movement key.
  final LogicalKeyboardKey leftKey;

  /// The right movement key.
  final LogicalKeyboardKey rightKey;

  /// The up movement key.
  final LogicalKeyboardKey upKey;

  /// The down movement key.
  final LogicalKeyboardKey downKey;

  /// The horizontal movement direction.
  /// -1 is left, 0 is stationary, 1 is right.
  double _horizontalMovement = 0;

  /// The vertical movement direction.
  /// -1 is up, 0 is stationary, 1 is down.
  double _verticalMovement = 0;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Update horizontal movement direction
    if (keysPressed.contains(leftKey)) {
      _horizontalMovement = -1;
      parent.setState(SpaceshipState.left); // Change animation to left
    } else if (keysPressed.contains(rightKey)) {
      _horizontalMovement = 1;
      parent.setState(SpaceshipState.right); // Change animation to right
    } else {
      _horizontalMovement = 0;
      if (_verticalMovement == 0) {
        parent.setState(SpaceshipState.idle); // Change animation to idle
      }
    }

    // Update vertical movement direction
    if (keysPressed.contains(upKey)) {
      _verticalMovement = -1;
    } else if (keysPressed.contains(downKey)) {
      _verticalMovement = 1;
    } else {
      _verticalMovement = 0;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    // Apply horizontal movement
    parent.position.x += _horizontalMovement * parent.speed * dt;

    // Apply vertical movement
    parent.position.y += _verticalMovement * parent.speed * dt;

    // Clamp horizontal position to screen bounds
    parent.position.x = parent.position.x.clamp(
      parent.size.x / 2,
      game.size.x - parent.size.x / 2,
    );

    // Clamp vertical position to the bottom half of the screen
    parent.position.y = (bloc.state.missionComplete)
        ? parent.position.y
        : parent.position.y.clamp(
            game.size.y / 2, // Limit to the lower half of the screen
            game.size.y - parent.size.y / 2, // Bottom boundary
          );
  }
}
