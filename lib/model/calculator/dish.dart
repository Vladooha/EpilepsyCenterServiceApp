import 'package:frontend/model/calculator/product.dart';

class Dish {
  static const int PRECISION = 3;

  final String id;
  final Product product;

  double weight;

  Dish(
    this.id,
    this.product,
    { this.weight = Product.NORMALIZED_WEIGHT_GRAMM});

  String get name => product.name;

  double get proteins => product.getProteins();
  double get fats => product.getFats();
  double get carbohydrates => product.getCarbohydrates();

  double get proteinsSummary => product.getProteins(weight: weight);
  double get fatsSummary => product.getFats(weight: weight);
  double get carbohydratesSummary => product.getCarbohydrates(weight: weight);

  double get cholesterol => product.getCholesterol();
  double get sodium => product.getSodium();
  double get ballast => product.getBallast();

  double get cholesterolSummary => product.getCholesterol(weight: weight);
  double get sodiumSummary => product.getSodium(weight: weight);
  double get ballastSummary => product.getBallast(weight: weight);

  double getWeight() => _round(weight);
  void setWeight(double value) => weight = _round(value);

  double _round(double value, {int precision = PRECISION})
    => double.parse(value.toStringAsFixed(precision));
}