import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
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

  @override
  Color backgroundColor() => const Color(0xFF2A48DF);

  @override
  Future<void> onLoad() async {
    final world = World(
      children: [
        // Unicorn(position: size / 2),
        // CounterComponent(
        //   position: (size / 2)
        //     ..sub(
        //       Vector2(0, 16),
        //     ),
        // ),
        // Add the spaceship at the bottom of the screen
        Spaceship(position: Vector2(size.x / 2, size.y - 32)),

        // Add the alien spawner
        AlienSpawner(
          maxAliens: 8,
          spawnInterval: 4,
        ),
      ],
    );

    final camera = CameraComponent(world: world);
    await addAll([world, camera]);

    camera.viewfinder.position = size / 2;
    // camera.viewfinder.zoom = 8;
  }
}
