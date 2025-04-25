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

  /// Current spawn interval
  double _currentInterval;

  /// Random number generator
  final _random = Random();

  /// Timer to track when to spawn next alien
  double _timer = 0;

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
