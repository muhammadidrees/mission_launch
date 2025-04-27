import 'package:equatable/equatable.dart';
import 'package:mission_launch/game/config/game_config.dart';
import 'package:mission_launch/game/game.dart';

/// {@template game_event}
/// Base class for all game events.
/// {@endtemplate}
abstract class GameEvent extends Equatable {
  /// {@macro game_event}
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// {@template game_tick}
/// Event emitted on every game tick to update time and progress.
/// {@endtemplate}
class GameTick extends GameEvent {
  /// {@macro game_tick}
  const GameTick({required this.deltaTime});

  /// Time elapsed since the last tick in seconds
  final double deltaTime;

  @override
  List<Object?> get props => [deltaTime];
}

/// {@template rocket_damaged}
/// Event emitted when the rocket takes damage.
/// {@endtemplate}
class RocketDamaged extends GameEvent {
  /// {@macro rocket_damaged}
  const RocketDamaged({this.damageAmount = 1});

  /// Amount of damage taken
  final int damageAmount;

  @override
  List<Object?> get props => [damageAmount];
}

/// {@template rocket_speed_changed}
/// Event emitted when the rocket speed changes.
/// {@endtemplate}
class RocketSpeedChanged extends GameEvent {
  /// {@macro rocket_speed_changed}
  const RocketSpeedChanged({required this.newSpeed});

  /// The new rocket speed
  final double newSpeed;

  @override
  List<Object?> get props => [newSpeed];
}

/// {@template score_increased}
/// Event emitted when the player's score increases.
/// {@endtemplate}
class ScoreIncreased extends GameEvent {
  /// {@macro score_increased}
  const ScoreIncreased({required this.amount});

  /// Amount to increase the score by
  final int amount;

  @override
  List<Object?> get props => [amount];
}

/// {@template game_config_changed}
/// Event emitted when the game configuration changes.
/// {@endtemplate}
class GameConfigChanged extends GameEvent {
  /// {@macro game_config_changed}
  const GameConfigChanged({required this.newConfig});

  /// New game configuration
  final GameConfig newConfig;

  @override
  List<Object?> get props => [newConfig];
}

/// {@template game_reset}
/// Event emitted to reset the game.
/// {@endtemplate}
class GameReset extends GameEvent {
  /// {@macro game_reset}
  const GameReset({this.config});

  /// Optional new configuration for the reset game
  final GameConfig? config;

  @override
  List<Object?> get props => [config];
}

/// {@template game_over}
/// Event emitted when the game is over.
/// {@endtemplate}
class GameOver extends GameEvent {
  /// {@macro game_over}
  const GameOver();
}

/// {@template phase_transition}
/// Event emitted when the game phase changes.
/// {@endtemplate}
class PhaseTransition extends GameEvent {
  /// {@macro phase_transition}
  const PhaseTransition({required this.newPhase});

  /// The new game phase
  final GamePhase newPhase;

  @override
  List<Object?> get props => [newPhase];
}
