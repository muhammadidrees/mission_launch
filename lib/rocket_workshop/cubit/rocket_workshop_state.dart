part of 'rocket_workshop_cubit.dart';

const double kTotalMoney = 1000;
const double kHealthPrice = 100;
const double kSpeedPrice = 100;
const double kBulletSpeedPrice = 200;

class RocketWorkshopState extends Equatable {
  const RocketWorkshopState({
    this.playerName = '',
    this.rocketName = '',
    this.health = 1,
    this.speed = 1,
    this.bulletSpeed = 1,
  });

  final String playerName;
  final String rocketName;
  final int health;
  final int speed;
  final int bulletSpeed;

  RocketWorkshopState copyWith({
    double? spentMoney,
    String? playerName,
    String? rocketName,
    int? health,
    int? speed,
    int? bulletSpeed,
  }) {
    return RocketWorkshopState(
      playerName: playerName ?? this.playerName,
      rocketName: rocketName ?? this.rocketName,
      health: health ?? this.health,
      speed: speed ?? this.speed,
      bulletSpeed: bulletSpeed ?? this.bulletSpeed,
    );
  }

  double get defaultAmount => kHealthPrice + kSpeedPrice + kBulletSpeedPrice;

  double get remainingMoney =>
      kTotalMoney -
      (health * kHealthPrice) -
      (speed * kSpeedPrice) -
      (bulletSpeed * kBulletSpeedPrice) +
      defaultAmount;

  int get maxHealth {
    // Calculate remaining money if we ignored health cost
    final moneyForHealth = kTotalMoney -
        (speed * kSpeedPrice) -
        (bulletSpeed * kBulletSpeedPrice) +
        (defaultAmount - kHealthPrice);

    // Calculate theoretical max from money
    final theoreticalMax = moneyForHealth ~/ kHealthPrice;

    // Apply game constraints
    if (speed < 5) {
      return min(theoreticalMax, 6);
    } else if (speed == 5) {
      return min(theoreticalMax, 5);
    } else if (speed >= 6) {
      return min(theoreticalMax, 4);
    }
    return min(theoreticalMax, 6); // Absolute max is 6
  }

  int get maxSpeed {
    // Calculate remaining money if we ignored speed cost
    final moneyForSpeed = kTotalMoney -
        (health * kHealthPrice) -
        (bulletSpeed * kBulletSpeedPrice) +
        (defaultAmount - kSpeedPrice);

    // Calculate theoretical max from money
    final theoreticalMax = moneyForSpeed ~/ kSpeedPrice;

    // Apply game constraints
    if (health < 5) {
      return min(theoreticalMax, 6);
    } else if (health == 5) {
      return min(theoreticalMax, 5);
    } else if (health >= 6) {
      return min(theoreticalMax, 4);
    }
    return min(theoreticalMax, 6); // Absolute max is 6
  }

  int get maxBulletSpeed {
    // Calculate remaining money available for bullet speed
    final moneyForBulletSpeed =
        remainingMoney + (defaultAmount - kBulletSpeedPrice);

    // Calculate theoretical max from remaining money
    final theoreticalMax = moneyForBulletSpeed ~/ kBulletSpeedPrice;

    // Absolute max is 4
    return min(theoreticalMax, 4);
  }

  @override
  List<Object> get props => [
        playerName,
        rocketName,
        health,
        speed,
        bulletSpeed,
      ];
}
