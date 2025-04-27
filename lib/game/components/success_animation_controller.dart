import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// {@template success_animation_controller}
/// A controller component that manages the success sequence:
/// 1. Explodes all enemies on screen
/// 2. Makes the rocket fly away
/// 3. Plays celebratory music
/// {@endtemplate}
class SuccessAnimationController extends Component
    with
        HasGameReference<MissionLaunch>,
        FlameBlocReader<GameBloc, GameState>,
        FlameBlocListenable<GameBloc, GameState> {
  /// {@macro success_animation_controller}
  SuccessAnimationController();

  /// Tracks if the animation sequence has been started
  bool _animationStarted = false;

  /// Duration to wait after destroying enemies before moving the rocket
  final double _waitAfterExplosions = 1;

  /// Time tracker for stages of the animation sequence
  double _elapsedTime = 0;

  /// The sequence stage (0=not started, 1=explosion phase, 2=rocket flying)
  int _sequenceStage = 0;

  /// Reference to the player's spaceship
  Spaceship? _spaceship;

  @override
  void onNewState(GameState state) {
    // Start animation sequence when successAnimationActive becomes true
    if (state.successAnimationActive && !_animationStarted) {
      _startSuccessAnimation();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_animationStarted) return;

    _elapsedTime += dt;

    // Handle rocket flying away after enemies explode
    if (_sequenceStage == 1 && _elapsedTime >= _waitAfterExplosions) {
      _flyRocketAway();
      _sequenceStage = 2;
    }
  }

  /// Starts the success animation sequence
  void _startSuccessAnimation() {
    _animationStarted = true;
    _sequenceStage = 1;
    _elapsedTime = 0.0;

    // Find the player spaceship
    _spaceship = game.children
        .whereType<World>()
        .first
        .children
        .whereType<Spaceship>()
        .firstOrNull;

    // First step: explode all enemies
    _explodeAllEnemies();

    // Play success sound
    AudioManager.instance.playEffect();
  }

  /// Explodes all enemies on screen with fancy visuals
  void _explodeAllEnemies() {
    // Find the game world
    final world = game.children.whereType<World>().firstOrNull;
    if (world == null) return;

    // Explode all aliens
    final aliens = world.children.whereType<Alien>().toList();
    for (final alien in aliens) {
      _createExplosion(alien.position, alien.size * 1.5);
      alien.removeFromParent();
    }

    // Explode all drones
    final drones = world.children.whereType<Drone>().toList();
    for (final drone in drones) {
      _createExplosion(drone.position, drone.size * 1.2);
      drone.removeFromParent();
    }

    // Explode all asteroids
    final asteroids = world.children.whereType<Asteroid>().toList();
    for (final asteroid in asteroids) {
      _createExplosion(asteroid.position, asteroid.size * 1.2);
      asteroid.removeFromParent();
    }
  }

  /// Makes the rocket fly away toward the top of the screen
  void _flyRocketAway() {
    if (_spaceship == null) return;

    print("puppo");

    // Add an animation to move the spaceship upwards
    _spaceship?.add(
      MoveByEffect(
        Vector2(0, -game.size.y * 1.2), // Move off the top of the screen
        EffectController(
          duration: 3,
          curve: Curves.easeInOut,
          onMax: () {
            // Show the success overlay when rocket finishes flying away
            // This is a safety check - the game should already have shown
            // the success overlay by now from GameProgressionManager
            if (!game.hasOverlay('success')) {
              game.overlays.add('success');
            }
          },
        ),
      ),
    );
  }

  /// Creates an explosion effect at the given position
  void _createExplosion(Vector2 position, Vector2 size) {
    final rng = Random();

    // Create fancy explosion animation
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
      position: position,
      size: size,
      anchor: Anchor.center,
      removeOnFinish: true,
    );

    // Add some randomness to each explosion's size and rotation
    explosion.scale = Vector2.all(0.8 + rng.nextDouble() * 0.8);
    explosion.angle = rng.nextDouble() * pi * 2;

    // Play explosion sound with slight delay for more natural feel
    Future.delayed(
      Duration(milliseconds: rng.nextInt(200)),
      () => AudioManager.instance.playAsteroidExplode(),
    );

    // Add the explosion to the game
    game.add(explosion);
  }
}
