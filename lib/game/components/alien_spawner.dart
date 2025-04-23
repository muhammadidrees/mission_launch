import 'dart:math';

import 'package:flame/components.dart';
import 'package:mission_launch/game/game.dart';

/// {@template alien_spawner}
/// A component that spawns aliens at random positions on the screen.
/// {@endtemplate}
class AlienSpawner extends Component with HasGameReference<MissionLaunch> {
  /// {@macro alien_spawner}
  AlienSpawner({
    this.spawnInterval = 3,
    this.initialAliens = 3,
    this.maxAliens = 5,
  });

  /// The time interval between spawning aliens (in seconds).
  final double spawnInterval;

  /// The number of aliens to spawn initially.
  final int initialAliens;

  /// The maximum number of aliens allowed on screen.
  final int maxAliens;

  /// Timer to track spawn intervals.
  double _spawnTimer = 0;

  /// Random number generator for positions.
  final _random = Random();

  @override
  Future<void> onLoad() async {
    // Spawn the initial aliens
    for (var i = 0; i < initialAliens; i++) {
      _spawnAlien();
    }
  }

  @override
  void update(double dt) {
    _spawnTimer += dt;

    // Check if it's time to spawn a new alien
    if (_spawnTimer >= spawnInterval) {
      _spawnTimer = 0;

      // Only spawn if we haven't reached the maximum
      final currentAliens = game.children.whereType<Alien>().length;
      if (currentAliens < maxAliens) {
        _spawnAlien();
      }
    }
  }

  /// Spawns an alien at a random position on the screen.
  void _spawnAlien() {
    // Generate a random position within the screen bounds
    final x = _random.nextDouble() * game.size.x;
    final y = _random.nextDouble() * game.size.y;

    // Create and add the alien to the game
    final alien = Alien(
      position: Vector2(x, y),
    );

    game.add(alien);
  }
}
