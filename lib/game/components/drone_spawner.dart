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
    this.maxDrones = 8,
    this.largeTypeProbability = 0.3,
    this.difficultyIncrease = 0.05,
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

  /// Current spawn interval
  double _currentInterval;

  /// Random number generator
  final _random = Random();

  /// Timer to track when to spawn next drone
  double _timer = 0;

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

    // Generate a random position on the screen
    // Keep drones within 10-90% of screen dimensions
    // to avoid spawning too close to edges
    final x = screenWidth * (0.1 + _random.nextDouble() * 0.8);
    final y = screenHeight *
        (0.1 + _random.nextDouble() * 0.5); // Upper 60% of screen

    final position = Vector2(x, y);

    // Determine drone type
    final droneType = _random.nextDouble() < largeTypeProbability
        ? DroneType.large
        : DroneType.small;

    // Create and add the drone
    final drone = Drone(
      position: position,
      type: droneType,
    );

    game.add(drone);
  }
}
