import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/game.dart';

/// Defines the different phases of gameplay during the journey from Earth to Moon
enum GamePhase {
  /// Phase 1: Only drones (0-60 seconds)
  earthOrbit,

  /// Phase 2: Drones + asteroids (60-120 seconds)
  deepSpace,

  /// Phase 3: Drones + asteroids + aliens (120-180 seconds)
  lunarApproach,

  /// Mission complete - reached the Moon
  missionComplete,
}

/// {@template game_progression_manager}
/// Manages the game progression including:
/// - Tracking progress through the mission
/// - Controlling which enemy types spawn based on current phase
/// - Displaying a progress bar showing journey from Earth to Moon
/// {@endtemplate}
class GameProgressionManager extends PositionComponent
    with HasGameReference<MissionLaunch> {
  /// {@macro game_progression_manager}
  GameProgressionManager({
    this.totalMissionDuration = 180.0, // 3 minutes in seconds
    this.progressBarWidth = 200.0,
    this.progressBarHeight = 15.0,
    Vector2? position,
  }) : _elapsedTime = 0 {
    this.position = position ?? Vector2.zero();
  }

  /// Total mission duration in seconds (Earth to Moon)
  final double totalMissionDuration;

  /// Width of the progress bar
  final double progressBarWidth;

  /// Height of the progress bar
  final double progressBarHeight;

  /// Current elapsed time in seconds
  double _elapsedTime;

  /// Current phase of the game
  GamePhase _currentPhase = GamePhase.earthOrbit;

  /// Whether drones can spawn
  bool _dronesEnabled = true;

  /// Whether asteroids can spawn
  bool _asteroidsEnabled = false;

  /// Whether aliens can spawn
  bool _aliensEnabled = false;

  /// Get current phase
  GamePhase get currentPhase => _currentPhase;

  /// Check if drones are enabled
  bool get dronesEnabled => _dronesEnabled;

  /// Check if asteroids are enabled
  bool get asteroidsEnabled => _asteroidsEnabled;

  /// Check if aliens are enabled
  bool get aliensEnabled => _aliensEnabled;

  /// Get progress as a value between 0.0 and 1.0
  double get progress => _elapsedTime / totalMissionDuration;

  /// Get remaining time in seconds
  double get remainingTime => totalMissionDuration - _elapsedTime;

  /// Get elapsed time in seconds
  double get elapsedTime => _elapsedTime;

  @override
  void onLoad() {
    super.onLoad();
    size = Vector2(progressBarWidth, progressBarHeight);

    // Position the progress bar at the top center of the screen
    position = Vector2(
      (game.size.x - progressBarWidth) / 2,
      20,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update elapsed time
    _elapsedTime += dt;

    // Cap at total mission duration
    _elapsedTime = min(_elapsedTime, totalMissionDuration);

    // Update phase based on elapsed time
    _updatePhase();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

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

    // Draw progress bar fill
    final progressRect = Rect.fromLTWH(
      0,
      0,
      progressBarWidth * progress,
      progressBarHeight,
    );

    // Color changes based on phase
    final progressColor = _getProgressColor();
    canvas.drawRect(
      progressRect,
      Paint()..color = progressColor,
    );

    // Draw border around progress bar
    canvas.drawRect(
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
    _drawSpaceshipMarker(canvas);
  }

  void _updatePhase() {
    final phaseTime = totalMissionDuration / 3;

    if (_elapsedTime < phaseTime) {
      // Phase 1: Earth orbit - Only drones
      _currentPhase = GamePhase.earthOrbit;
      _dronesEnabled = true;
      _asteroidsEnabled = false;
      _aliensEnabled = false;
    } else if (_elapsedTime < phaseTime * 2) {
      // Phase 2: Deep space - Drones + asteroids
      _currentPhase = GamePhase.deepSpace;
      _dronesEnabled = true;
      _asteroidsEnabled = true;
      _aliensEnabled = false;
    } else if (_elapsedTime < totalMissionDuration) {
      // Phase 3: Lunar approach - All enemies
      _currentPhase = GamePhase.lunarApproach;
      _dronesEnabled = true;
      _asteroidsEnabled = true;
      _aliensEnabled = true;
    } else {
      // Mission complete
      _currentPhase = GamePhase.missionComplete;
    }
  }

  Color _getProgressColor() {
    switch (_currentPhase) {
      case GamePhase.earthOrbit:
        return Colors.blue;
      case GamePhase.deepSpace:
        return Colors.purple;
      case GamePhase.lunarApproach:
        return Colors.orange;
      case GamePhase.missionComplete:
        return Colors.green;
    }
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

  void _drawSpaceshipMarker(Canvas canvas) {
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
