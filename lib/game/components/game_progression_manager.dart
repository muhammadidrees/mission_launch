import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/game.dart';

/// {@template game_progression_manager}
/// Manages the visual representation of game progression including:
/// - Displaying a progress bar showing journey from Earth to Moon
/// - Showing different colors based on the current phase
/// - Handling mission success UI when 100% is reached
/// {@endtemplate}
class GameProgressionManager extends PositionComponent
    with HasGameReference<MissionLaunch>, FlameBlocReader<GameBloc, GameState>, FlameBlocListenable<GameBloc, GameState> {
  /// {@macro game_progression_manager}
  GameProgressionManager({
    this.progressBarWidth = 200.0,
    this.progressBarHeight = 15.0,
    Vector2? position,
    this.visibleOnUI = true,
  }) {
    this.position = position ?? Vector2.zero();
  }

  /// Width of the progress bar
  final double progressBarWidth;

  /// Height of the progress bar
  final double progressBarHeight;

  /// Whether to display the progress bar on screen
  final bool visibleOnUI;

  /// Flag to track if mission success has been triggered
  bool _missionSuccessTriggered = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(progressBarWidth, progressBarHeight);

    // Position the progress bar at the top center of the screen
    position = Vector2(
      (game.size.x - progressBarWidth) / 2,
      20,
    );

    // Make this component accessible to everyone who needs it
    priority = 1000; // High priority to make sure it updates first
  }

  @override
  void onNewState(GameState state) {
    // Check for mission success (100% progress and mission complete phase)
    if (state.progressPercent >= 100 && 
        state.phase == GamePhase.missionComplete &&
        !_missionSuccessTriggered) {
      _handleMissionSuccess();
    }
  }
  
  // Handle mission success
  void _handleMissionSuccess() {
    // Only trigger this once
    if (_missionSuccessTriggered) return;
    _missionSuccessTriggered = true;
    
    // Add mission success overlay
    if (game.hasOverlay('game_over')) {
      game.overlays.remove('game_over');
    }
    
    // Add success overlay if it exists
    game.overlays.add('success');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Only render if we're configured to be visible
    if (!visibleOnUI) return;

    // Draw progress bar background
    final backgroundRect = Rect.fromLTWH(
      0,
      0,
      progressBarWidth,
      progressBarHeight,
    );
    canvas.drawRect(
      backgroundRect,
      Paint()..color = Colors.grey.withOpacity(0.5),
    );

    // Calculate progress from the bloc
    final progress = bloc.state.progress;

    // Draw progress bar fill
    final progressRect = Rect.fromLTWH(
      0,
      0,
      progressBarWidth * progress,
      progressBarHeight,
    );

    // Get color from the bloc
    final progressColor = bloc.state.phaseColor;
    canvas
      ..drawRect(
        progressRect,
        Paint()..color = progressColor,
      )

      // Draw border around progress bar
      ..drawRect(
        backgroundRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

    // Draw small Earth icon at start
    _drawEarth(canvas);

    // Draw small Moon icon at end
    _drawMoon(canvas);

    // Draw spaceship indicator on progress bar
    _drawSpaceshipMarker(canvas, progress);
  }

  void _drawEarth(Canvas canvas) {
    final earthRadius = progressBarHeight * 0.9;
    final earthCenter = Offset(-earthRadius - 5, progressBarHeight / 2);

    // Draw Earth (blue circle)
    canvas.drawCircle(
      earthCenter,
      earthRadius,
      Paint()..color = Colors.blue,
    );
  }

  void _drawMoon(Canvas canvas) {
    final moonRadius = progressBarHeight * 0.7;
    final moonCenter = Offset(
      progressBarWidth + moonRadius + 5,
      progressBarHeight / 2,
    );

    // Draw Moon (grey circle)
    canvas.drawCircle(
      moonCenter,
      moonRadius,
      Paint()..color = Colors.grey[300]!,
    );
  }

  void _drawSpaceshipMarker(Canvas canvas, double progress) {
    final markerHeight = progressBarHeight * 1.5;
    final markerWidth = markerHeight * 0.5;
    final x = progressBarWidth * progress;

    // Create triangle path for spaceship marker
    final path = Path()
      ..moveTo(x, -5) // Top point
      ..lineTo(x - markerWidth / 2, -5 - markerHeight) // Bottom left
      ..lineTo(x + markerWidth / 2, -5 - markerHeight) // Bottom right
      ..close();

    // Draw spaceship marker
    canvas.drawPath(
      path,
      Paint()..color = Colors.white,
    );
  }
}
