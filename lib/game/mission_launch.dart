import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:mission_launch/game/components/asteroid_spawner.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/l10n/l10n.dart';

class MissionLaunch extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  MissionLaunch({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required Images images,
  }) {
    this.images = images;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  int counter = 0;

  /// Reference to the player's spaceship
  late Spaceship _spaceship;

  @override
  bool get debugMode => true;

  @override
  Color backgroundColor() => const Color(0xFF2A48DF);

  @override
  Future<void> onLoad() async {
    // Create the player spaceship
    _spaceship = Spaceship(
      position: Vector2(size.x / 2, size.y - 80),
    );

    // Create the game world with all entities
    final world = World(
      children: [
        // Add the spaceship at the bottom of the screen
        _spaceship,

        // Add the alien spawner
        AlienSpawner(
          maxAliens: 8,
          spawnInterval: 4,
        ),

        AsteroidSpawner(),
      ],
    );

    // Create a UI component for displaying health and other UI elements
    final uiComponent = PositionComponent()

      // Add health display to the UI
      ..add(
        HealthDisplayComponent(
          spaceship: _spaceship,
          position: Vector2(10, 10),
          heartSize: 24,
        ),
      );

    // Create and configure the game camera
    final camera = CameraComponent(
      world: world,
    );

    // Add all components to the game
    await addAll([world, camera, uiComponent]);

    camera.viewfinder.position = size / 2;
  }
}
