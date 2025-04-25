import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/entities/spaceship/behaviors/behaviors.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// Defines the different states of the spaceship
enum SpaceshipState {
  idle,
  left,
  right,
}

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
          size: Vector2(40, 56),
          scale: Vector2.all(2),
          behaviors: [
            KeyboardMovingBehavior(),
            ShootingBehavior(cooldown: 0.2),
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
  
  /// The current state of the spaceship
  SpaceshipState _currentState = SpaceshipState.idle;
  
  /// Map to store animations for different states
  final Map<SpaceshipState, SpriteAnimation> _animations = {};
  
  /// The sprite animation component for the spaceship
  SpriteAnimationComponent? _animationComponent;

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
  
  /// Sets the state of the spaceship and updates its animation
  void setState(SpaceshipState state) {
    if (_currentState == state || isDestroyed) return;
    
    _currentState = state;
    _updateAnimation();
  }
  
  /// Updates the spaceship animation to match the current state
  void _updateAnimation() {
    if (_animationComponent != null && _animations.containsKey(_currentState)) {
      _animationComponent!.animation = _animations[_currentState];
    }
  }

  @override
  Future<void> onLoad() async {
    // Load all spaceship animations
    _animations[SpaceshipState.idle] = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.spaceshipIdle.path),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(40, 56),
      ),
    );
    
    _animations[SpaceshipState.left] = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.spaceshipLeft.path),
      SpriteAnimationData.sequenced(
        amount: 4, // Update this if your left animation has a different number of frames
        stepTime: 0.1,
        textureSize: Vector2(40, 56),
      ),
    );
    
    _animations[SpaceshipState.right] = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.spaceshipRight.path),
      SpriteAnimationData.sequenced(
        amount: 4, // Update this if your right animation has a different number of frames
        stepTime: 0.1,
        textureSize: Vector2(40, 56),
      ),
    );
    
    // Create the animation component with the idle animation initially
    _animationComponent = SpriteAnimationComponent(
      animation: _animations[SpaceshipState.idle],
      size: size,
    );
    
    await add(_animationComponent!);
  }
}
