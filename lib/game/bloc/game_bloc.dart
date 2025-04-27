import 'package:bloc/bloc.dart';
import 'package:mission_launch/game/bloc/game_event.dart';
import 'package:mission_launch/game/bloc/game_state.dart';
import 'package:mission_launch/game/config/game_config.dart';

/// Defines the different phases of gameplay
///  during the journey from Earth to Moon
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

/// {@template game_bloc}
/// A bloc that manages the game state.
/// {@endtemplate}
class GameBloc extends Bloc<GameEvent, GameState> {
  /// {@macro game_bloc}
  GameBloc({GameConfig? config}) : super(GameState.initial(config: config)) {
    on<GameTick>(_onGameTick);
    on<RocketDamaged>(_onRocketDamaged);
    on<RocketSpeedChanged>(_onRocketSpeedChanged);
    on<ScoreIncreased>(_onScoreIncreased);
    on<GameConfigChanged>(_onGameConfigChanged);
    on<GameReset>(_onGameReset);
    on<GameOver>(_onGameOver);
    on<PhaseTransition>(_onPhaseTransition);
    on<MissionCompleted>(_onMissionCompleted);
  }

  void _onGameTick(GameTick event, Emitter<GameState> emit) {
    // Skip ticks if the game is over or mission is complete
    if (state.isGameOver || state.missionComplete) return;

    // Calculate how much time to advance based on rocket speed
    final speedRatio = state.rocketSpeed / state.config.initialRocketSpeed;
    final speedFactor = speedRatio * state.config.progressionSpeedMultiplier;
    final adjustedDelta = event.deltaTime * speedFactor;

    // Calculate new elapsed time
    final newElapsedTime = state.elapsedTime + adjustedDelta;

    // Determine the current phase based on elapsed time
    final newPhase = _determinePhase(newElapsedTime);

    // Check if the phase has changed
    final phaseChanged = newPhase != state.phase;

    // Check if we've reached mission complete (100% progress)
    final reachedComplete = newPhase == GamePhase.missionComplete &&
        state.phase != GamePhase.missionComplete;

    // Emit the updated state
    emit(
      state.copyWith(
        elapsedTime: newElapsedTime,
        phase: newPhase,
        phaseTransitioned: phaseChanged,
      ),
    );

    // If the phase changed, emit a phase transition event
    if (phaseChanged) {
      add(PhaseTransition(newPhase: newPhase));
    }

    // If we've reached mission complete, trigger the mission completed event
    if (reachedComplete) {
      add(const MissionCompleted());
    }

    // Reset the phaseTransitioned flag after a brief delay if needed
    if (state.phaseTransitioned) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (isClosed) return;
        emit(state.copyWith(phaseTransitioned: false));
      });
    }
  }

  void _onRocketDamaged(RocketDamaged event, Emitter<GameState> emit) {
    // Skip if the game is already over
    if (state.isGameOver) return;

    // Calculate new health
    final newHealth = state.rocketHealth - event.damageAmount;

    // Check for game over
    if (newHealth <= 0) {
      emit(state.copyWith(rocketHealth: 0, isGameOver: true));
      add(const GameOver());
      return;
    }

    // Otherwise update health
    emit(state.copyWith(rocketHealth: newHealth));
  }

  void _onRocketSpeedChanged(
    RocketSpeedChanged event,
    Emitter<GameState> emit,
  ) {
    // Cap the speed at the configured maximum
    final cappedSpeed = event.newSpeed.clamp(
      0.0,
      state.config.maxRocketSpeed,
    );

    emit(state.copyWith(rocketSpeed: cappedSpeed));
  }

  void _onScoreIncreased(ScoreIncreased event, Emitter<GameState> emit) {
    final newScore = state.score + event.amount;
    emit(state.copyWith(score: newScore));
  }

  void _onGameConfigChanged(
    GameConfigChanged event,
    Emitter<GameState> emit,
  ) {
    emit(state.copyWith(config: event.newConfig));
  }

  void _onGameReset(GameReset event, Emitter<GameState> emit) {
    emit(GameState.initial(config: event.config ?? state.config));
  }

  void _onGameOver(GameOver event, Emitter<GameState> emit) {
    emit(state.copyWith(isGameOver: true));
  }

  void _onPhaseTransition(PhaseTransition event, Emitter<GameState> emit) {
    // This method can be used to trigger any special effects or
    // actions when the phase changes
    emit(state.copyWith(phase: event.newPhase));
  }

  void _onMissionCompleted(MissionCompleted event, Emitter<GameState> emit) {
    // Set the mission complete flag
    emit(state.copyWith(missionComplete: true));
  }

  /// Determine the current game phase based on elapsed time
  GamePhase _determinePhase(double elapsedTime) {
    final phaseRatios = state.config.normalizedPhaseRatios;
    final totalDuration = state.config.totalMissionDuration;

    // Calculate phase transition points
    final phase1Duration = totalDuration * phaseRatios[0];
    final phase2Duration = totalDuration * phaseRatios[1];

    if (elapsedTime < phase1Duration) {
      return GamePhase.earthOrbit;
    } else if (elapsedTime < phase1Duration + phase2Duration) {
      return GamePhase.deepSpace;
    } else if (elapsedTime < totalDuration) {
      return GamePhase.lunarApproach;
    } else {
      return GamePhase.missionComplete;
    }
  }
}
