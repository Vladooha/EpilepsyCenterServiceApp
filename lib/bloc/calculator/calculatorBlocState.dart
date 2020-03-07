import 'package:frontend/model/calculator/dailyEating.dart';
import 'package:frontend/model/calculator/product.dart';

abstract class CalculatorBlocState {}



abstract class DailyEatingState extends CalculatorBlocState {}

class GettingDailyEating extends DailyEatingState {}
class GotDailyEating extends DailyEatingState {
  DailyEating dailyEating;

  GotDailyEating(this.dailyEating);
}

class SavingDailyEating extends DailyEatingState {}
class SavedDailyEating extends DailyEatingState {}



abstract class ProductState extends CalculatorBlocState {}

class GettingProducts extends ProductState {}
class GotProducts extends ProductState {
  final List<Product> products;

  GotProducts(this.products);
}