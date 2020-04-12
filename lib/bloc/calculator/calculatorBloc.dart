import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:frontend/bloc/calculator/calculatorBlocEvent.dart';
import 'package:frontend/bloc/calculator/calculatorBlocState.dart';
import 'package:frontend/model/calculator/dailyEating.dart';
import 'package:frontend/model/calculator/eatingType.dart';
import 'package:frontend/model/calculator/product.dart';
import 'package:frontend/model/calculator/singleEating.dart';
import 'package:frontend/model/calculator/dish.dart';
import 'package:frontend/service/ioc/abstractBloc.dart';
import 'package:rxdart/rxdart.dart';

class CalculatorBloc extends AbstractBloc {
  /// Test data
  List<Product> productList = [
    Product("1", name: "Гречка1", proteins: 1, fats: 1, carbohydrates: 0),
    Product("12", name: "Гречка2", proteins: 1, fats: 1, carbohydrates: 0),
    Product("13", name: "Гречка3", proteins: 1, fats: 1, carbohydrates: 0),
    Product("14", name: "Гречка4", proteins: 1, fats: 1, carbohydrates: 0),
    Product("15", name: "Гречка5", proteins: 1, fats: 1, carbohydrates: 0),
    Product("16", name: "Гречка6", proteins: 1, fats: 1, carbohydrates: 0),
    Product("16666", name: "Гречка666", proteins: 1, fats: 1, carbohydrates: 0),
    Product("2", name: "Рис", proteins: 30, fats: 50, carbohydrates: 200),
    Product("3", name: "Продукт с очень длинным наименованием и значениями переменных", proteins: 9999999999999, fats: 99999999999, carbohydrates: 999999999),
    Product("sdsdg", name: "Тест", proteins: 123, fats: 456, carbohydrates: 789, cholesterol: 987, sodium: 654, ballast: 321),
    Product("dfhh", name: "Брюссельская капуста заморозка HORTEX")
  ];

  List<DailyEating> dailyEatingList = [];

  void initTestDailyEatings() {
    List<Dish> dishes = [
      Dish("1", productList[0]),
      Dish("2", productList[1], weight: 133.0),
      Dish("3", productList[2], weight: 1500.2),
      Dish("3", productList[3], weight: 1511.2),
      Dish("3", productList[4], weight: 1522.2),
      Dish("3", productList[7], weight: 15.22),
      Dish("3", productList[8], weight: 166.2),
      Dish("273r6273623ad2eg3", productList[9]),
    ];

    Random random = Random(DateTime.now().millisecondsSinceEpoch);
    DateTime today = DateTime.now();
    int daysInHistory = 15;
    for (int diff = 0; diff < daysInHistory; diff++) {
      List<SingleEating> allSingleEatings = getAllSingleEatings();
      for (SingleEating singleEating in allSingleEatings) {
        int dishCount = random.nextInt(4);
        for (int i = 0; i < dishCount; i++) {
          int dishIndex = random.nextInt(dishes.length);
          singleEating.dishes.add(dishes[dishIndex]);
        }
      }

      DailyEating dailyEating = DailyEating(
          diff.toString(),
          date: today.subtract(Duration(days: diff)));

      _fillDailyBySingleEatings(dailyEating, allSingleEatings);

      dailyEatingList.add(dailyEating);
    }
  }
  
  List<SingleEating> getAllSingleEatings() => [
      SingleEating("1", mealTime: Eating.breakfast),
      SingleEating("2", mealTime: Eating.dinner),
      SingleEating("3", mealTime: Eating.launch),
      SingleEating("4", mealTime: Eating.evening),
      SingleEating("5", mealTime: Eating.snack),
      SingleEating("6", mealTime: Eating.night),
    ];
  
  static const String BLOC_NAME = "calculator-bloc";

  BehaviorSubject<CalculatorBlocEvent> _eventListener;
  BehaviorSubject<DailyEatingState> _dailyEatingsStreamController;
  BehaviorSubject<ProductState> _productsStreamController;

  Sink<CalculatorBlocEvent> get eventListener => _eventListener.sink;
  Stream<DailyEatingState> get dailyEatings =>
      _dailyEatingsStreamController.stream.asBroadcastStream();
  Stream<ProductState> get products =>
      _productsStreamController.stream.asBroadcastStream();
  ProductState get lastProducts =>
      _productsStreamController.value;

  @override
  bool init() {
    if (super.init()) {
      _eventListener = BehaviorSubject<CalculatorBlocEvent>();
      _dailyEatingsStreamController = BehaviorSubject<DailyEatingState>();
      _productsStreamController = BehaviorSubject<ProductState>();

      _productsStreamController.add(GettingProducts());

      _eventListener.stream.listen(_eventToStateMapper);

      initTestDailyEatings();

      return true;
    }

    return false;
  }

  @override
  String get name => BLOC_NAME;

  void _eventToStateMapper(CalculatorBlocEvent event) {
    if (event is GetDailyEating) {
      _getDailyMealTime(event.date);
    } else if (event is SaveDailyEating) {

    } else if (event is GetProducts) {
      _getProducts();
    } else if (event is AddProduct) {
      _addProduct(event.product);
    } else if (event is DeleteProduct) {
      _deleteProduct(event.productId);
    }
  }

  // TODO: Replace hardcoded values with base connection
  _getDailyMealTime(DateTime date) {
    _dailyEatingsStreamController.sink.add(GettingDailyEating());

    DailyEating dailyEating =
        dailyEatingList.firstWhere(
              (dailyEating) => dailyEating.date.difference(date)
                                  .compareTo(Duration(days: 1)) < 0,
              orElse: () => _createEmptyDailyEating(date));

    _dailyEatingsStreamController.sink.add(GotDailyEating(dailyEating));
  }

  _getProducts() {
    _productsStreamController.sink.add(GettingProducts());

    _productsStreamController.sink.add(GotProducts(productList));
  }
  
  _deleteProduct(String productId) {
    dailyEatingList.forEach(
        (dailyEating) =>
            dailyEating.singleEatings.forEach(
                (eatingType, singleEating) => 
                    singleEating.dishes.removeWhere(
                        (dish) => dish.product.id == productId)));
    
    productList.removeWhere((product) => product.id == productId);
    
    _getProducts();
  }

  _addProduct(Product product) {
    productList.add(product);

    _getProducts();
  }

  _createEmptyDailyEating(DateTime date) {
    DailyEating emptyDailyEating = DailyEating(null, date: date);

    List<SingleEating> emptySingleEating = [
      SingleEating(null, mealTime: Eating.breakfast),
      SingleEating(null, mealTime: Eating.dinner),
      SingleEating(null, mealTime: Eating.launch),
      SingleEating(null, mealTime: Eating.evening),
      SingleEating(null, mealTime: Eating.snack),
      SingleEating(null, mealTime: Eating.night),
    ];

    _fillDailyBySingleEatings(emptyDailyEating, emptySingleEating);

    return emptyDailyEating;
  }

  _fillDailyBySingleEatings(DailyEating dailyEating, List<SingleEating> singleEatings) {
    singleEatings.forEach(
            (singleEating) => dailyEating.singleEatings[singleEating.mealTime] = singleEating);
  }

  @override
  bool dispose() {
    _eventListener.close();
    _dailyEatingsStreamController.close();
    _productsStreamController.close();

    return super.dispose();
  }
}