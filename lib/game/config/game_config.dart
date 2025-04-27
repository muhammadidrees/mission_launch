import 'package:equatable/equatable.dart';

/// {@template game_config}
/// Configuration settings for the game, including phase timings,
/// spawn rates, and difficulty parameters.
/// {@endtemplate}
class GameConfig extends Equatable {
  /// {@macro game_config}
  const GameConfig({
    required this.totalMissionDuration,
    required this.phaseRatios,
    required this.maxDrones,
    required this.maxAsteroids,
    required this.maxAliens,
    this.initialRocketSpeed = 120.0,
    this.maxRocketSpeed = 240.0,
    this.rocketAcceleration = 10.0,
    this.progressionSpeedMultiplier = 1.0,
    this.droneSpawnInterval = 5.0,
    this.droneDifficultyIncrease = 0.05,
    this.asteroidSpawnInterval = 3.0,
    this.asteroidDifficultyIncrease = 0.05,
    this.alienSpawnInterval = 8.0,
    this.alienDifficultyIncrease = 0.08,
  }) : assert(
          phaseRatios.length == 3,
          'phaseRatios must have 3 values for Earth orbit, Deep space, '
          'and Lunar approach',
        );

  /// Hard difficulty preset with shorter mission and more enemies
  factory GameConfig.hard() {
    return GameConfig(
      totalMissionDuration: 150, // 2.5 minutes
      phaseRatios: const [1, 1.5, 2.5], // Progressively longer phases
      maxDrones: 5,
      maxAsteroids: 4,
      maxAliens: 4,
      initialRocketSpeed: 140,
      maxRocketSpeed: 280,
      rocketAcceleration: 15,
      progressionSpeedMultiplier: 1.2,
      droneSpawnInterval: 4,
      droneDifficultyIncrease: 0.08,
      asteroidSpawnInterval: 2.5,
      asteroidDifficultyIncrease: 0.1,
      alienSpawnInterval: 6,
      alienDifficultyIncrease: 0.12,
    );
  }

  /// Easy difficulty preset with longer mission duration and fewer enemies
  factory GameConfig.easy() {
    return GameConfig(
      totalMissionDuration: 30, // 30 seconds
      phaseRatios: const [1, 1, 1], // Even phases
      maxDrones: 3,
      maxAsteroids: 2,
      maxAliens: 2,
      initialRocketSpeed: 100,
      maxRocketSpeed: 200,
      rocketAcceleration: 5,
      progressionSpeedMultiplier: 0.8,
      droneSpawnInterval: 6,
      droneDifficultyIncrease: 0.03,
      asteroidSpawnInterval: 4,
      asteroidDifficultyIncrease: 0.03,
      alienSpawnInterval: 10,
      alienDifficultyIncrease: 0.05,
    );
  }

  /// Normal difficulty preset
  factory GameConfig.normal() {
    return GameConfig(
      totalMissionDuration: 180, // 3 minutes
      phaseRatios: const [1, 1, 2], // Last phase twice as long
      maxDrones: 4,
      maxAsteroids: 3,
      maxAliens: 3,
    );
  }

  /// Total time for mission in seconds
  final double totalMissionDuration;

  /// List of 3 values representing ratios for Earth orbit, Deep space,
  /// and Lunar approach phases. For example [1, 1, 2] means the
  /// last phase is twice as long.
  final List<double> phaseRatios;

  /// Maximum number of drones that can be active at once
  final int maxDrones;

  /// Maximum number of asteroids that can be active at once
  final int maxAsteroids;

  /// Maximum number of aliens that can be active at once
  final int maxAliens;

  /// Initial speed of the rocket
  final double initialRocketSpeed;

  /// Maximum speed the rocket can achieve
  final double maxRocketSpeed;

  /// How quickly the rocket accelerates
  final double rocketAcceleration;

  /// Multiplier for how much rocket speed affects progression
  final double progressionSpeedMultiplier;

  /// Base interval between drone spawns in seconds
  final double droneSpawnInterval;

  /// How much drone spawn interval decreases after each spawn
  final double droneDifficultyIncrease;

  /// Base interval between asteroid spawns in seconds
  final double asteroidSpawnInterval;

  /// How much asteroid spawn interval decreases after each spawn
  final double asteroidDifficultyIncrease;

  /// Base interval between alien spawns in seconds
  final double alienSpawnInterval;

  /// How much alien spawn interval decreases after each spawn
  final double alienDifficultyIncrease;

  /// Returns the phase ratios normalized (summing to 1.0)
  List<double> get normalizedPhaseRatios {
    final sum = phaseRatios.fold<double>(0, (sum, ratio) => sum + ratio);
    return phaseRatios.map((ratio) => ratio / sum).toList();
  }

  /// Creates a copy of this config with the given parameters replaced
  GameConfig copyWith({
    double? totalMissionDuration,
    List<double>? phaseRatios,
    int? maxDrones,
    int? maxAsteroids,
    int? maxAliens,
    double? initialRocketSpeed,
    double? maxRocketSpeed,
    double? rocketAcceleration,
    double? progressionSpeedMultiplier,
    double? droneSpawnInterval,
    double? droneDifficultyIncrease,
    double? asteroidSpawnInterval,
    double? asteroidDifficultyIncrease,
    double? alienSpawnInterval,
    double? alienDifficultyIncrease,
  }) {
    return GameConfig(
      totalMissionDuration: totalMissionDuration ?? this.totalMissionDuration,
      phaseRatios: phaseRatios ?? this.phaseRatios,
      maxDrones: maxDrones ?? this.maxDrones,
      maxAsteroids: maxAsteroids ?? this.maxAsteroids,
      maxAliens: maxAliens ?? this.maxAliens,
      initialRocketSpeed: initialRocketSpeed ?? this.initialRocketSpeed,
      maxRocketSpeed: maxRocketSpeed ?? this.maxRocketSpeed,
      rocketAcceleration: rocketAcceleration ?? this.rocketAcceleration,
      progressionSpeedMultiplier:
          progressionSpeedMultiplier ?? this.progressionSpeedMultiplier,
      droneSpawnInterval: droneSpawnInterval ?? this.droneSpawnInterval,
      droneDifficultyIncrease:
          droneDifficultyIncrease ?? this.droneDifficultyIncrease,
      asteroidSpawnInterval:
          asteroidSpawnInterval ?? this.asteroidSpawnInterval,
      asteroidDifficultyIncrease:
          asteroidDifficultyIncrease ?? this.asteroidDifficultyIncrease,
      alienSpawnInterval: alienSpawnInterval ?? this.alienSpawnInterval,
      alienDifficultyIncrease:
          alienDifficultyIncrease ?? this.alienDifficultyIncrease,
    );
  }

  @override
  List<Object?> get props => [
        totalMissionDuration,
        phaseRatios,
        maxDrones,
        maxAsteroids,
        maxAliens,
        initialRocketSpeed,
        maxRocketSpeed,
        rocketAcceleration,
        progressionSpeedMultiplier,
        droneSpawnInterval,
        droneDifficultyIncrease,
        asteroidSpawnInterval,
        asteroidDifficultyIncrease,
        alienSpawnInterval,
        alienDifficultyIncrease,
      ];
}
