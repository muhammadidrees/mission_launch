import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mission_launch/game/game.dart';

/// {@template health_display}
/// A component that displays the health status of a spaceship.
/// {@endtemplate}
class HealthDisplayComponent extends PositionComponent
    with HasGameReference<MissionLaunch> {
  /// {@macro health_display}
  HealthDisplayComponent({
    required this.spaceship,
    required super.position,
    this.heartSize = 20,
    this.spacing = 5,
  }) : super(anchor: Anchor.topLeft);

  /// The spaceship to track health for
  final Spaceship spaceship;

  /// Size of each heart icon
  final double heartSize;

  /// Spacing between heart icons
  final double spacing;

  /// The list of heart components
  final List<HeartComponent> _hearts = [];

  @override
  Future<void> onLoad() async {
    // Calculate width based on max health
    size = Vector2(
      spaceship.maxHealth * (heartSize + spacing) - spacing,
      heartSize,
    );

    // Create heart components
    for (var i = 0; i < spaceship.maxHealth; i++) {
      final heart = HeartComponent(
        size: Vector2.all(heartSize),
        position: Vector2(i * (heartSize + spacing), 0),
      );
      _hearts.add(heart);
      add(heart);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update heart display based on current health
    for (var i = 0; i < _hearts.length; i++) {
      _hearts[i].filled = i < spaceship.health;
    }
  }
}

/// A component that renders a heart icon (filled or empty).
class HeartComponent extends PositionComponent {
  /// Creates a new heart component.
  HeartComponent({
    required super.size,
    required super.position,
    this.filled = true,
    this.filledColor = Colors.red,
    this.emptyColor = Colors.grey,
  }) : super(anchor: Anchor.topLeft);

  /// Whether the heart is filled or empty
  bool filled;

  /// Color of filled hearts
  final Color filledColor;

  /// Color of empty hearts
  final Color emptyColor;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = filled ? filledColor : emptyColor
      ..style = PaintingStyle.fill;

    // Draw a heart shape
    final path = Path();
    final center = size / 2;
    final width = size.x;
    final height = size.y;

    // Draw heart shape using bezier curves
    path
      ..moveTo(center.x, height * 0.85)
      ..cubicTo(
        width * 0.75,
        height * 0.6,
        width * 1.1,
        height * 0.3,
        center.x,
        height * 0.25,
      )
      ..cubicTo(
        width * -0.1,
        height * 0.3,
        width * 0.25,
        height * 0.6,
        center.x,
        height * 0.85,
      );

    canvas.drawPath(path, paint);
  }
}
