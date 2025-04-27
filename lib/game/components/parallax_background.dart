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
      // size: Vector2(100, 100),
      // baseVelocity: Vector2(0, -baseVelocity),
      // repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
      alignment: Alignment.bottomCenter,
    );

    parallax = _parallax;
  }

  // @override
  // void onNewState(GameState state) {
  //   // if (!isMounted) return;
  //   // // Calculate total distance the background needs to move (the entire height)
  //   // final totalDistance = size.y / 100;

  //   // // Calculate velocity needed to finish exactly when progress reaches 100%
  //   // // This creates a consistent speed that will complete exactly at 100% progress
  //   // final remainingProgress = 100 - state.progressPercent;
  //   // if (remainingProgress > 0) {
  //   //   // If we're not at 100%, calculate velocity to finish right at 100%
  //   //   final velocityNeeded = (totalDistance * baseVelocity) / remainingProgress;
  //   //   _parallax.baseVelocity = Vector2(0, -velocityNeeded);
  //   // } else {
  //   //   // We've reached 100%, stop scrolling
  //   //   _parallax.baseVelocity = Vector2.zero();
  //   // }
  // }

  // @override
  // void update(double dt) {
  //   super.update(dt);

  //   var height = size.y;

  //   var c = height / baseVelocity;

  //   // Update the parallax position based on the base velocity
  //   _parallax.baseVelocity = Vector2(0, -baseVelocity * c);

  //   // Adjust scroll speed based on game phase
  //   // final progressManager = game.progressionManager;
  //   // final phase = progressManager.currentPhase;

  //   // // Speed increases as the game progresses through phases
  //   // double speedMultiplier;
  //   // switch (phase) {
  //   //   case GamePhase.earthOrbit:
  //   //     speedMultiplier = 1.0;
  //   //   case GamePhase.deepSpace:
  //   //     speedMultiplier = 1.5;
  //   //   case GamePhase.lunarApproach:
  //   //     speedMultiplier = 2.0;
  //   //   case GamePhase.missionComplete:
  //   //     speedMultiplier = 0.5; // Slow down when mission is complete
  //   // }

  //   // // Update the scroll velocity
  //   // _parallax.baseVelocity.y = -baseVelocity * speedMultiplier;
  // }
}
