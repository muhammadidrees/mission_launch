import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/painting.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/l10n/l10n.dart';

class MissionLaunch extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  MissionLaunch({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required Images images,
    required this.gameBloc,
  }) {
    this.images = images;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  final GameBloc gameBloc;

  int counter = 0;

  /// Reference to the player's spaceship
  late Spaceship _spaceship;

  /// Reference to the game progression manager
  late GameProgressionManager progressionManager;

  @override
  bool get debugMode => false;

  @override
  Color backgroundColor() => const Color(0xFF050A30);

  @override
  Future<void> onLoad() async {
    // Create the player spaceship
    _spaceship = Spaceship(
      position: Vector2(size.x / 2, size.y - 80),
    );

    // Create the progression manager first, so it's available
    // to all components
    progressionManager = GameProgressionManager(
      progressBarWidth: size.x * 0.6, // Make it 60% of screen width
      progressBarHeight: 18,
    );

    // Add progression manager to the game first so it's
    // available to all components
    await add(progressionManager);

    await add(
      // Add the parallax background as the first
      // element so it appears behind everything else
      ParallaxBackgroundComponent(baseVelocity: 10),
    );

    // Create the game world with all entities
    final world = World(
      children: [
        // Add the spaceship at the bottom of the screen
        _spaceship,

        // Add the alien spawner
        AlienSpawner(maxAliens: 4),

        AsteroidSpawner(),

        DroneSpawner(),
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
    await addAll([
      FlameBlocProvider<GameBloc, GameState>.value(
        value: gameBloc,
        children: [world],
      ),
      camera,
      uiComponent,
    ]);

    camera.viewfinder.position = size / 2;
  }

  /// Get the current phase of the game
  GamePhase get currentPhase => progressionManager.currentPhase;

  /// Get the progress as a percentage (0-100)
  int get progressPercent => progressionManager.progressPercent;

  /// Get the name of the current phase
  String get phaseName => progressionManager.phaseName;

  /// Get remaining time formatted as mm:ss
  String get remainingTime => progressionManager.remainingTimeFormatted;

  /// Get elapsed time formatted as mm:ss
  String get elapsedTime => progressionManager.elapsedTimeFormatted;

  /// Get the color associated with the current phase
  Color get phaseColor => progressionManager.phaseColor;
}
