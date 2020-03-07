import 'package:frontend/model/calculator/dailyEating.dart';
import 'package:frontend/model/calculator/product.dart';

abstract class CalculatorBlocEvent {}

class GetDailyEating extends CalculatorBlocEvent {
  final DateTime date;

  GetDailyEating(this.date);
}
class SaveDailyEating extends CalculatorBlocEvent {
  final DailyEating dailyEating;

  SaveDailyEating(this.dailyEating);
}

class GetProducts extends CalculatorBlocEvent { }
class AddProduct extends CalculatorBlocEvent {
  final Product product;

  AddProduct(this.product);
}
class DeleteProduct extends CalculatorBlocEvent {
  final String productId;

  DeleteProduct(this.productId);
}