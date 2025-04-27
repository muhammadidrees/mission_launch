import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'rocket_workshop_state.dart';

class RocketWorkshopCubit extends Cubit<RocketWorkshopState> {
  RocketWorkshopCubit() : super(const RocketWorkshopState());

  void setPlayerName(String name) {
    emit(state.copyWith(playerName: name));
  }

  void setRocketName(String name) {
    emit(state.copyWith(rocketName: name));
  }

  void setRocketHealth(int health) {
    emit(state.copyWith(health: health));
  }

  void setRocketSpeed(int speed) {
    emit(state.copyWith(speed: speed));
  }

  void setBulletSpeed(int bulletSpeed) {
    emit(state.copyWith(bulletSpeed: bulletSpeed));
  }
}
