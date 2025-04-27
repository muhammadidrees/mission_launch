import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// {@template parallax_background}
/// A component that renders a scrolling background with parallax effect.
/// The background scrolls vertically to give the impression of the spaceship
/// moving through space.
/// {@endtemplate}
class ParallaxBackgroundComponent extends ParallaxComponent<MissionLaunch> {
  /// {@macro parallax_background}
  ParallaxBackgroundComponent({this.baseVelocity = 1});

  /// Base velocity for the parallax effect in pixels per second
  final double baseVelocity;

  /// Reference to the loaded parallax
  late Parallax _parallax;

  @override
  Future<void> onLoad() async {
    // Load the background image
    _parallax = await game.loadParallax(
      [
        ParallaxImageData(Assets.images.bacground.path),
      ],
      size: Vector2.all(size.y * 200),
      baseVelocity: Vector2(0, -baseVelocity),
      // repeat: ImageRepeat.repeat,
      alignment: Alignment.bottomCenter,
    );

    parallax = _parallax;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Adjust scroll speed based on game phase
    final progressManager = game.progressionManager;
    final phase = progressManager.currentPhase;

    // Speed increases as the game progresses through phases
    double speedMultiplier;
    switch (phase) {
      case GamePhase.earthOrbit:
        speedMultiplier = 1.0;
      case GamePhase.deepSpace:
        speedMultiplier = 1.5;
      case GamePhase.lunarApproach:
        speedMultiplier = 2.0;
      case GamePhase.missionComplete:
        speedMultiplier = 0.5; // Slow down when mission is complete
    }

    // Update the scroll velocity
    _parallax.baseVelocity.y = -baseVelocity * speedMultiplier;
  }
}
