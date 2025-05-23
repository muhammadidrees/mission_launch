import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/config/game_config.dart';

const kBulletCooldown = 0.5;

/// {@template game_state}
/// Represents the current state of the game.
/// {@endtemplate}
class GameState extends Equatable {
  /// {@macro game_state}
  const GameState({
    required this.config,
    required this.rocketSpeed,
    required this.elapsedTime,
    required this.rocketHealth,
    required this.maxRocketHealth,
    required this.score,
    required this.phase,
    this.maxDrones = 3,
    this.maxAsteroids = 2,
    this.maxAliens = 2,
    this.coolBulletCooldown = kBulletCooldown,
    this.isGameOver = false,
    this.phaseTransitioned = false,
    this.missionComplete = false,
    this.successAnimationActive = false,
  });

  /// Initial game state
  factory GameState.initial({GameConfig? config}) {
    final gameConfig = config ?? GameConfig.normal();

    return GameState(
      config: gameConfig,
      rocketSpeed: gameConfig.maxRocketSpeed,
      elapsedTime: 0,
      rocketHealth: gameConfig.maxRocketHealth,
      maxRocketHealth: gameConfig.maxRocketHealth,
      maxDrones: gameConfig.maxDrones,
      maxAsteroids: gameConfig.maxAsteroids,
      maxAliens: gameConfig.maxAliens,
      coolBulletCooldown: kBulletCooldown - gameConfig.coolBulletCooldown,
      score: 0,
      phase: GamePhase.earthOrbit,
    );
  }

  /// Current game configuration
  final GameConfig config;

  /// Current rocket speed
  final double rocketSpeed;

  /// Elapsed time in seconds
  final double elapsedTime;

  /// Current rocket health
  final int rocketHealth;

  /// Maximum rocket health
  final int maxRocketHealth;

  /// Maximum number of drones
  final int maxDrones;

  /// Maximum number of asteroids
  final int maxAsteroids;

  /// Maximum number of aliens
  final int maxAliens;

  /// Cooldown time
  final double coolBulletCooldown;

  /// Current game score
  final int score;

  /// Current game phase
  final GamePhase phase;

  /// Whether the game is over
  final bool isGameOver;

  /// Whether the phase has just transitioned - useful for effects
  final bool phaseTransitioned;

  /// Whether the mission is complete (reached 100% and final phase)
  final bool missionComplete;

  /// Whether the success animation sequence is currently active
  final bool successAnimationActive;

  /// Progress of the journey (0.0 - 1.0)
  double get progress {
    // Calculate progress based on normalized phase ratios
    final phaseRatios = config.normalizedPhaseRatios;
    double progressValue = 0;

    switch (phase) {
      case GamePhase.earthOrbit:
        // In phase 1, progress is relative to phase 1 duration
        progressValue =
            elapsedTime / (config.totalMissionDuration * phaseRatios[0]);
        if (progressValue > 1.0) progressValue = 1.0;
        return progressValue * phaseRatios[0];

      case GamePhase.deepSpace:
        // In phase 2, progress is phase 1 plus relative progress in phase 2
        final phase2Time =
            elapsedTime - (config.totalMissionDuration * phaseRatios[0]);
        final phase2Progress =
            phase2Time / (config.totalMissionDuration * phaseRatios[1]);
        return phaseRatios[0] + (phase2Progress * phaseRatios[1]);

      case GamePhase.lunarApproach:
        // In phase 3, progress is phase 1 + 2 plus relative progress in phase 3
        final phase3Time = elapsedTime -
            (config.totalMissionDuration * (phaseRatios[0] + phaseRatios[1]));
        final phase3Progress =
            phase3Time / (config.totalMissionDuration * phaseRatios[2]);
        final calculatedProgress =
            phaseRatios[0] + phaseRatios[1] + (phase3Progress * phaseRatios[2]);
        return calculatedProgress.clamp(0.0, 1.0);

      case GamePhase.missionComplete:
        return 1;
    }
  }

  /// Progress as a percentage (0-100)
  int get progressPercent => (progress * 100).round();

  /// Get remaining time in seconds
  double get remainingTime => config.totalMissionDuration - elapsedTime;

  /// Get remaining time formatted as mm:ss
  String get remainingTimeFormatted {
    final minutes = (remainingTime / 60).floor();
    final seconds = (remainingTime % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get elapsed time formatted as mm:ss
  String get elapsedTimeFormatted {
    final minutes = (elapsedTime / 60).floor();
    final seconds = (elapsedTime % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get the name of the current phase
  String get phaseName {
    switch (phase) {
      case GamePhase.earthOrbit:
        return 'Earth Orbit';
      case GamePhase.deepSpace:
        return 'Deep Space';
      case GamePhase.lunarApproach:
        return 'Lunar Approach';
      case GamePhase.missionComplete:
        return 'Moon Reached!';
    }
  }

  /// Get the color for the current phase
  Color get phaseColor {
    switch (phase) {
      case GamePhase.earthOrbit:
        return Colors.blue;
      case GamePhase.deepSpace:
        return Colors.purple;
      case GamePhase.lunarApproach:
        return Colors.orange;
      case GamePhase.missionComplete:
        return Colors.green;
    }
  }

  /// Check if drones are enabled in current phase
  bool get dronesEnabled => phase != GamePhase.missionComplete && !gameStop;

  /// Check if asteroids are enabled in current phase
  bool get asteroidsEnabled =>
      (phase == GamePhase.deepSpace || phase == GamePhase.lunarApproach) &&
      !gameStop;

  /// Check if aliens are enabled in current phase
  bool get aliensEnabled => phase == GamePhase.lunarApproach && !gameStop;

  bool get gameStop => missionComplete || isGameOver;

  /// Copy this state with some new values
  GameState copyWith({
    GameConfig? config,
    double? rocketSpeed,
    double? elapsedTime,
    int? rocketHealth,
    int? maxRocketHealth,
    int? score,
    GamePhase? phase,
    bool? isGameOver,
    bool? phaseTransitioned,
    bool? missionComplete,
    bool? successAnimationActive,
  }) {
    return GameState(
      maxDrones: maxDrones,
      maxAsteroids: maxAsteroids,
      maxAliens: maxAliens,
      config: config ?? this.config,
      rocketSpeed: rocketSpeed ?? this.rocketSpeed,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      rocketHealth: rocketHealth ?? this.rocketHealth,
      maxRocketHealth: maxRocketHealth ?? this.maxRocketHealth,
      score: score ?? this.score,
      phase: phase ?? this.phase,
      isGameOver: isGameOver ?? this.isGameOver,
      phaseTransitioned: phaseTransitioned ?? this.phaseTransitioned,
      missionComplete: missionComplete ?? this.missionComplete,
      successAnimationActive:
          successAnimationActive ?? this.successAnimationActive,
    );
  }

  @override
  List<Object> get props => [
        config,
        rocketSpeed,
        elapsedTime,
        rocketHealth,
        maxRocketHealth,
        maxDrones,
        maxAsteroids,
        maxAliens,
        coolBulletCooldown,
        score,
        phase,
        isGameOver,
        phaseTransitioned,
        missionComplete,
        successAnimationActive,
      ];
}
