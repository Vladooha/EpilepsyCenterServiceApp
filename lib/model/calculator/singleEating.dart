import 'dart:collection';

import 'package:frontend/model/calculator/eatingType.dart';
import 'package:frontend/model/calculator/dish.dart';

class SingleEating {
  final String id;

  EatingType mealTime;
  final List<Dish> dishes = [];

  SingleEating(
    this.id, {
      this.mealTime
  });
}