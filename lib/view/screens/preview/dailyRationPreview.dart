import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/calculator/eatingType.dart';
import 'package:frontend/model/calculator/nutrient.dart';
import 'package:frontend/view/uiparts/cardPart.dart';
import 'package:frontend/view/uiparts/customTextPart.dart';
import 'package:frontend/view/uiparts/tablePart.dart';

class EatingView {
  static const String BREAKFAST_NAME = "Завтрак";
  static const String DINNER_NAME = "Обед";
  static const String LAUNCH_NAME = "Полдник";
  static const String EVENING_MEAL_NAME = "Ужин";
  static const String SNACK_NAME = "Перекус";
  static const String NIGHT_MEAL_NAME = "Ночь";

  final Eating eating;

  EatingView(this.eating);

  String get name {
    if (eating == Eating.dinner) {
      return DINNER_NAME;
    }

    if (eating == Eating.launch) {
      return LAUNCH_NAME;
    }

    if (eating == Eating.evening) {
      return EVENING_MEAL_NAME;
    }

    if (eating == Eating.snack) {
      return SNACK_NAME;
    }

    if (eating == Eating.night) {
      return NIGHT_MEAL_NAME;
    }

    return BREAKFAST_NAME;
  }
}

class NutrientView {
  static const PROTEINS_NAME = "Белки";
  static const FATS_NAME = "Жиры";
  static const CARBOHYDRATES_NAME = "Углеводы";

  static const PERFECT_MIN = 45;
  static const PERFECT_MAX = 55;
  static const NORMAL_MIN = 35;
  static const NORMAL_MAX = 65;

  static final Color PERFECT_COLOR = Colors.greenAccent;
  static final Color NORMAL_COLOR = Colors.orange;
  static final Color BAD_COLOR = Colors.red;

  final Nutrient nutrient;
  double value;

  NutrientView(this.nutrient, {this.value = 0.0});

  Color get color {
    if (PERFECT_MIN <= value && value <= PERFECT_MAX) {
      return PERFECT_COLOR;
    }

    if (NORMAL_MIN <= value && value <= NORMAL_MAX) {
      return NORMAL_COLOR;
    }

    return BAD_COLOR;
  }

  String get name {
    if (nutrient == Nutrient.proteins) {
      return PROTEINS_NAME;
    }

    if (nutrient == Nutrient.fats) {
      return FATS_NAME;
    }

    return CARBOHYDRATES_NAME;
  }

  String get shortName {
    if (nutrient == Nutrient.proteins) {
      return "Б: ";
    }

    if (nutrient == Nutrient.fats) {
      return "Ж: ";
    }

    return "У: ";
  }
}

class DailyRationPreview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DailyRationPreviewState();
}

class DailyRationPreviewState extends State<DailyRationPreview> with CardPart, TablePart, CustomTextPart {
  Map<Eating, NutrientView> proteinViewMap = {};
  Map<Eating, NutrientView> fatViewMap = {};
  Map<Eating, NutrientView> carbohydratesViewMap = {};

  @override
  void initState() {
    super.initState();

    Random random = Random();

    for (Eating eating in Eating.values) {
      proteinViewMap[eating] = NutrientView(
          Nutrient.proteins,
          value: 70 * random.nextDouble()
      );

      fatViewMap[eating] = NutrientView(
          Nutrient.fats,
          value: 100 * random.nextDouble()
      );

      carbohydratesViewMap[eating] = NutrientView(
          Nutrient.carbohydrates,
          value: 50 * random.nextDouble()
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.purple,
        accentColor: Colors.grey[600],
        fontFamily: 'Pacifico',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Дневное меню"),
        ),
        body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                 itemCount: Eating.values.length,
                 itemBuilder: (context, index) {
                    EatingView eatingView = EatingView(Eating.values[index]);

                    return _createMenuPosition(eatingView);
                 }
                ),
              ),
              _createTable(),
              _createButtons()
            ]
          ),
        )
    );
  }

  Widget _createMenuPosition(EatingView eatingView) {
    var protFatsCarbTotal = RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black),
        children: [
          TextSpan(text: proteinViewMap[eatingView.eating].shortName),
          TextSpan(
            text: '${proteinViewMap[eatingView.eating].value.round()} ',
            style: TextStyle(color: proteinViewMap[eatingView.eating].color)
          ),
          TextSpan(text: fatViewMap[eatingView.eating].shortName),
          TextSpan(
              text: '${fatViewMap[eatingView.eating].value.round()} ',
              style: TextStyle(color: fatViewMap[eatingView.eating].color)
          ),
          TextSpan(text: fatViewMap[eatingView.eating].shortName),
          TextSpan(
              text: '${fatViewMap[eatingView.eating].value.round()} ',
              style: TextStyle(color: fatViewMap[eatingView.eating].color)
          ),
        ]
      )
    );

    return createCard(
      ListTile(
        title: Text(eatingView.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: protFatsCarbTotal,
        trailing: Icon(Icons.edit),
      ),
      padding: 5.0,
      elevation: 3.0
    );
  }
  
  Widget _createTable() {
    double perfectValue =
        (NutrientView.PERFECT_MAX + NutrientView.PERFECT_MIN) / 2 * 6;
    double proteinsValue =
      proteinViewMap.values
          .fold(0.0, (previousValue, element) => previousValue + element.value);
    double fatsValue =
      fatViewMap.values
          .fold(0.0, (previousValue, element) => previousValue + element.value);
    double carbohydratesValue =
      carbohydratesViewMap.values
          .fold(0.0, (previousValue, element) => previousValue + element.value);

    return Column(
      children: [
        Text("Итого: "),
        createTable([
          createTableRow(
              NutrientView.PROTEINS_NAME,
              value: "${proteinsValue.round()} из ${perfectValue}"
          ),
          createTableRow(
              NutrientView.FATS_NAME,
              value: "${fatsValue.round()} из ${perfectValue}"
          ),
          createTableRow(
              NutrientView.CARBOHYDRATES_NAME,
              value: "${carbohydratesValue.round()} из ${perfectValue}"
          ),
        ]),
      ],
    );
  }
  
  Widget _createButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: MaterialButton(
            color: Colors.purple,
            child: Text("Назад"),
            onPressed: () {},
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: MaterialButton(
            color: Colors.purple,
            child: Text("Сохранить"),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}