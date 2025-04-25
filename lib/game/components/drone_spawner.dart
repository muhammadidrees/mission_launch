import 'dart:math';
import 'package:flame/components.dart';
import 'package:mission_launch/game/game.dart';

/// A component that spawns enemy drones at random positions
class DroneSpawner extends Component with HasGameReference<MissionLaunch> {
  /// Creates a [DroneSpawner]
  DroneSpawner({
    this.spawnInterval = 5.0,
    this.minInterval = 3.0,
    this.maxInterval = 8.0,
    this.maxDrones = 4,
    this.largeTypeProbability = 0.3,
    this.difficultyIncrease = 0.05,
    this.minimumDistanceBetweenDrones = 100.0,
  }) : _currentInterval = spawnInterval;

  /// The max number of drones on screen at once
  final int maxDrones;

  /// The base interval between spawns in seconds
  final double spawnInterval;

  /// The minimum interval between spawns in seconds
  final double minInterval;

  /// The maximum interval between spawns in seconds
  final double maxInterval;

  /// Probability (0-1) that a spawned drone will be of large type
  final double largeTypeProbability;

  /// How much the spawn interval decreases per spawn
  final double difficultyIncrease;

  /// Minimum distance between drone positions to prevent overlapping
  final double minimumDistanceBetweenDrones;

  /// Current spawn interval
  double _currentInterval;

  /// Random number generator
  final _random = Random();

  /// Timer to track when to spawn next drone
  double _timer = 0;

  /// Maximum number of attempts to find a valid non-overlapping position
  static const int _maxPositionAttempts = 10;

  @override
  void onMount() {
    super.onMount();
    _currentInterval = spawnInterval;
  }

  @override
  void update(double dt) {
    _timer += dt;

    final currentDrones = game.children.whereType<Drone>().length;
    if (currentDrones >= maxDrones) {
      return; // Don't spawn if max drones already on screen
    }

    if (_timer >= _currentInterval) {
      _spawnDrone();
      _timer = 0;

      // Increase difficulty by reducing spawn interval
      _currentInterval = max(
        minInterval,
        _currentInterval - difficultyIncrease,
      );
    }
  }

  void _spawnDrone() {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    // Generate a target position for the drone (where it will hover)
    // Try several times to find a position that doesn't overlap with existing drones
    Vector2? targetPosition;
    int attempts = 0;

    while (targetPosition == null && attempts < _maxPositionAttempts) {
      // Generate a random position within the upper part of the screen
      // Keep drones within 10-90% of screen width and 10-50% of screen height
      final potentialX = screenWidth * (0.1 + _random.nextDouble() * 0.8);
      final potentialY = screenHeight * (0.1 + _random.nextDouble() * 0.4);

      final potentialPosition = Vector2(potentialX, potentialY);

      // Check if this position is far enough from all existing drones
      bool isValidPosition = true;
      final existingDrones = game.children.whereType<Drone>().toList();

      for (final drone in existingDrones) {
        if (drone.position.distanceTo(potentialPosition) <
            minimumDistanceBetweenDrones) {
          isValidPosition = false;
          break;
        }
      }

      if (isValidPosition) {
        targetPosition = potentialPosition;
      }

      attempts++;
    }

    // If we couldn't find a non-overlapping position after max attempts,
    // just use the last attempted position
    targetPosition ??= Vector2(screenWidth * (0.1 + _random.nextDouble() * 0.8),
        screenHeight * (0.1 + _random.nextDouble() * 0.4));

    // Choose a random edge of the screen to spawn from
    final side = _random.nextInt(3); // 0=top, 1=right, 2=left
    late Vector2 spawnPosition;

    switch (side) {
      case 0: // top
        spawnPosition = Vector2(_random.nextDouble() * screenWidth, -30);
      case 1: // right
        spawnPosition = Vector2(
            screenWidth + 30, _random.nextDouble() * screenHeight * 0.5);
      case 2: // left
        spawnPosition = Vector2(-30, _random.nextDouble() * screenHeight * 0.5);
    }

    // Determine drone type
    final droneType = _random.nextDouble() < largeTypeProbability
        ? DroneType.large
        : DroneType.small;

    // Create and add the drone
    final drone = Drone(
      position: spawnPosition,
      targetPosition: targetPosition,
      type: droneType,
    );

    game.add(drone);
  }
}
