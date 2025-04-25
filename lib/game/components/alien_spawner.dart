import 'dart:math';
import 'package:flame/components.dart';
import 'package:mission_launch/game/game.dart';

/// A component that spawns enemy aliens at random positions
class AlienSpawner extends Component with HasGameReference<MissionLaunch> {
  /// Creates an [AlienSpawner]
  AlienSpawner({
    this.spawnInterval = 8.0,
    this.minInterval = 5.0,
    this.maxInterval = 10.0,
    this.maxAliens = 5,
    this.largeTypeProbability = 0.25,
    this.difficultyIncrease = 0.08,
    this.minimumDistanceBetweenAliens = 120.0,
  }) : _currentInterval = spawnInterval;

  /// The max number of aliens on screen at once
  final int maxAliens;

  /// The base interval between spawns in seconds
  final double spawnInterval;

  /// The minimum interval between spawns in seconds
  final double minInterval;

  /// The maximum interval between spawns in seconds
  final double maxInterval;

  /// Probability (0-1) that a spawned alien will be of large type
  final double largeTypeProbability;

  /// How much the spawn interval decreases per spawn
  final double difficultyIncrease;

  /// Minimum distance between alien positions to prevent overlapping
  final double minimumDistanceBetweenAliens;

  /// Current spawn interval
  double _currentInterval;

  /// Random number generator
  final _random = Random();

  /// Timer to track when to spawn next alien
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

    final currentAliens = game.children.whereType<Alien>().length;
    if (currentAliens >= maxAliens) {
      return; // Don't spawn if max aliens already on screen
    }

    if (_timer >= _currentInterval) {
      _spawnAlien();
      _timer = 0;

      // Increase difficulty by reducing spawn interval
      _currentInterval = max(
        minInterval,
        _currentInterval - difficultyIncrease,
      );
    }
  }

  void _spawnAlien() {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    // Calculate a good target central position for the alien
    // This is where the alien will hover after flying in
    Vector2? centralPosition;
    int attempts = 0;

    while (centralPosition == null && attempts < _maxPositionAttempts) {
      // Calculate a position in the upper area of the screen
      final potentialX = screenWidth *
          (0.3 + _random.nextDouble() * 0.4); // 30-70% of screen width
      final potentialY = screenHeight *
          (0.15 + _random.nextDouble() * 0.25); // 15-40% of screen height

      final potentialPosition = Vector2(potentialX, potentialY);

      // Check if this position is far enough from all existing aliens and drones
      bool isValidPosition = true;

      // Check distance from other aliens
      final existingAliens = game.children.whereType<Alien>().toList();
      for (final alien in existingAliens) {
        if (alien.position.distanceTo(potentialPosition) <
            minimumDistanceBetweenAliens) {
          isValidPosition = false;
          break;
        }
      }

      // Also check distance from drones to avoid overlap with them
      if (isValidPosition) {
        final existingDrones = game.children.whereType<Drone>().toList();
        for (final drone in existingDrones) {
          if (drone.position.distanceTo(potentialPosition) <
              minimumDistanceBetweenAliens) {
            isValidPosition = false;
            break;
          }
        }
      }

      if (isValidPosition) {
        centralPosition = potentialPosition;
      }

      attempts++;
    }

    // If we couldn't find a non-overlapping position, use the last attempted position
    centralPosition ??= Vector2(
        screenWidth * (0.3 + _random.nextDouble() * 0.4),
        screenHeight * (0.15 + _random.nextDouble() * 0.25));

    // Choose a random side of the screen to spawn from (left or right)
    final spawnFromLeft = _random.nextBool();

    // X position is off-screen on either left or right side
    final x = spawnFromLeft ? -30.0 : screenWidth + 30.0;

    // Y position is in the top half of the screen
    final y = screenHeight * (0.1 + _random.nextDouble() * 0.3);

    final position = Vector2(x, y);

    // Determine alien type
    final alienType = _random.nextDouble() < largeTypeProbability
        ? AlienType.large
        : AlienType.small;

    // Create and add the alien
    final alien = Alien(
      position: position,
      type: alienType,
    );

    game.add(alien);
  }
}
