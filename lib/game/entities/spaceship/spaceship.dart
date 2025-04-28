import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/entities/spaceship/behaviors/behaviors.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// Defines the different states of the spaceship
enum SpaceshipState {
  idle,
  left,
  right,
  broken,
}

/// {@template spaceship}
/// A spaceship that can be controlled with left/right arrow keys.
/// {@endtemplate}
class Spaceship extends PositionedEntity
    with HasGameReference, FlameBlocListenable<GameBloc, GameState> {
  /// {@macro spaceship}
  Spaceship({
    required super.position,
    this.maxHealth = 3,
    this.invincibilityDuration = 1.5,
    this.speed = 200,
    this.cooldown = 0.5,
  }) : super(
          anchor: Anchor.center,
          size: Vector2(40, 56),
          scale: Vector2.all(2),
          behaviors: [
            KeyboardMovingBehavior(),
            ShootingBehavior(),
            PropagatingCollisionBehavior(
              RectangleHitbox(isSolid: true),
            ),
          ],
        ) {
    _health = maxHealth;
  }

  /// The maximum health of the spaceship
  final int maxHealth;

  /// Speed of the spaceship
  final int speed;

  /// Cooldown time for shooting (in seconds)
  final double cooldown;

  /// Duration of invincibility after taking damage (in seconds)
  final double invincibilityDuration;

  /// Current health of the spaceship
  int _health = 3;

  /// The current state of the spaceship
  SpaceshipState _currentState = SpaceshipState.idle;

  /// Map to store animations for different states
  final Map<SpaceshipState, SpriteAnimation> _animations = {};

  /// The sprite animation component for the spaceship
  SpriteAnimationComponent? _animationComponent;

  /// Whether the spaceship is currently invincible
  bool _isInvincible = false;

  /// Timer to track the blinking effect
  Timer? _blinkTimer;

  /// Get the current health
  int get health {
    if (!isMounted) return _health;
    return bloc.state.rocketHealth;
  }

  /// Check if the spaceship is destroyed (health <= 0)
  bool get isDestroyed => health <= 0;

  /// Check if the spaceship is currently invincible
  bool get isInvincible => _isInvincible;

  /// Decreases the health by the given amount
  void damage([int amount = 1]) {
    // Don't take damage if invincible or already destroyed
    if (_isInvincible || isDestroyed) return;

    _health -= amount;
    if (_health < 0) _health = 0;

    bloc.add(RocketDamaged(damageAmount: amount));

    // If spaceship is now destroyed, show the broken animation
    if (isDestroyed && _currentState != SpaceshipState.broken) {
      _currentState = SpaceshipState.broken;

      _updateAnimation();
    } else {
      _activateInvincibility();
    }
  }

  @override
  Future<void> onNewState(GameState state) async {
    if (state.isGameOver) {
      // Play explode sound
      AudioManager.instance.playSpaceShipExplode();
      _currentState = SpaceshipState.broken;
      _updateAnimation();
      game.overlays.add('game_over');
    }

    if (state.missionComplete) {
      _currentState = SpaceshipState.idle;
      _updateAnimation();

      _activateInvincibility();
    }
  }

  void _activateInvincibility() {
    _isInvincible = true;

    // Create blinking effect - toggle visibility every 0.15 seconds
    _blinkTimer = Timer(
      0.15,
      onTick: () {
        if (_animationComponent != null) {
          _animationComponent!.opacity =
              _animationComponent!.opacity > 0 ? 0 : 1;
        }
      },
      repeat: true,
    );

    // Add a timer to end invincibility after the set duration
    add(
      TimerComponent(
        period: invincibilityDuration,
        removeOnFinish: true,
        onTick: () {
          // End invincibility
          _isInvincible = false;

          // Stop blinking and ensure spaceship is fully visible
          _blinkTimer?.stop();
          if (_animationComponent != null) {
            _animationComponent!.opacity = 1;
          }
        },
      ),
    );
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
    await super.onLoad();
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
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(40, 56),
      ),
    );

    _animations[SpaceshipState.right] = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.spaceshipRight.path),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(40, 56),
      ),
    );

    // Load broken spaceship animation
    _animations[SpaceshipState.broken] = SpriteAnimation.fromFrameData(
      game.images.fromCache(Assets.images.spaceshipBroken.path),
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
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

  @override
  void update(double dt) {
    super.update(dt);

    bloc.add(GameTick(deltaTime: dt));

    if (bloc.state.missionComplete) {
      position.y -= 600 * dt;
      if (position.y < -size.y) {
        game.overlays.add('success');
      }
    }

    if (position.y > game.size.y + 10) {
      removeFromParent();
    }

    // Update blink timer if active
    _blinkTimer?.update(dt);
  }
}
