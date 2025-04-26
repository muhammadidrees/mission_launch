import 'dart:math';
import 'package:flame/components.dart';
import 'package:mission_launch/game/game.dart';

/// A component that spawns asteroids at random positions and intervals
class AsteroidSpawner extends Component with HasGameReference<MissionLaunch> {
  /// Creates an [AsteroidSpawner]
  AsteroidSpawner({
    this.spawnInterval = 3.0,
    this.minInterval = 1.0,
    this.maxInterval = 5.0,
    this.maxAsteroids = 4,
    this.targetSpaceshipProbability = 0.3,
    this.difficultyIncrease = 0.05,
  }) : _currentInterval = spawnInterval;

  /// The max number of asteroids on screen at once
  final int maxAsteroids;

  /// The base interval between spawns in seconds
  final double spawnInterval;

  /// The minimum interval between spawns in seconds
  final double minInterval;

  /// The maximum interval between spawns in seconds
  final double maxInterval;

  /// Probability (0-1) that an asteroid will target the spaceship
  final double targetSpaceshipProbability;

  /// How much the spawn interval decreases per spawn
  final double difficultyIncrease;

  /// Current spawn interval
  double _currentInterval;

  /// Random number generator
  final _random = Random();

  /// Timer to track when to spawn next asteroid
  double _timer = 0;

  /// Cached reference to the game progression manager
  GameProgressionManager? _progressionManager;

  @override
  void onMount() {
    super.onMount();
    _currentInterval = spawnInterval;
  }

  @override
  void update(double dt) {
    // Find progression manager if we haven't cached it yet
    _progressionManager ??=
        game.children.whereType<GameProgressionManager>().firstOrNull;

    // Don't spawn asteroids if progression manager says they're disabled
    if (_progressionManager != null && !_progressionManager!.asteroidsEnabled) {
      return;
    }

    _timer += dt;

    final currentAsteroids = game.children.whereType<Asteroid>().length;
    if (currentAsteroids >= maxAsteroids) {
      return; // Don't spawn if max asteroids already on screen
    }

    if (_timer >= _currentInterval) {
      _spawnAsteroid();
      _timer = 0;

      // Increase difficulty by reducing spawn interval
      _currentInterval = max(
        minInterval,
        _currentInterval - difficultyIncrease,
      );
    }
  }

  void _spawnAsteroid() {
    // Choose a random edge of the screen to spawn from
    final side = _random.nextInt(4); // 0=top, 1=right, 2=bottom, 3=left
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    // Calculate a random position along the chosen edge
    late Vector2 position;
    switch (side) {
      case 0: // top
        position = Vector2(_random.nextDouble() * screenWidth, -30);
      case 1: // right
        position =
            Vector2(screenWidth + 30, _random.nextDouble() * screenHeight);
      case 2: // bottom
        position =
            Vector2(_random.nextDouble() * screenWidth, screenHeight + 30);
      case 3: // left
        position = Vector2(-30, _random.nextDouble() * screenHeight);
    }

    // Decide if this asteroid should target the spaceship
    final targetSpaceship = _random.nextDouble() < targetSpaceshipProbability;

    // Choose a random direction if not targeting spaceship
    Vector2? direction;
    if (!targetSpaceship) {
      // Generate a direction that crosses the screen
      final targetX = _random.nextDouble() * screenWidth;
      final targetY = _random.nextDouble() * screenHeight;
      direction = Vector2(targetX, targetY) - position;
      direction = direction.normalized();
    }

    // Choose a random asteroid type
    final asteroidType =
        AsteroidType.values[_random.nextInt(AsteroidType.values.length)];

    // Choose a random base speed
    final baseSpeed = 80 + _random.nextInt(60); // 80-140 pixels per second

    // Create and add the asteroid
    final asteroid = Asteroid(
      position: position,
      type: asteroidType,
      baseSpeed: baseSpeed.toDouble(),
      targetSpaceship: targetSpaceship,
      direction: direction,
      rotationSpeed: (_random.nextDouble() - 0.5) * 2, // -1 to 1
    );

    game.add(asteroid);
  }
}
