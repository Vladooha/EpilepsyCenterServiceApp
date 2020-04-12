import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/view/uiparts/cardPart.dart';
import 'package:frontend/view/uiparts/customTextPart.dart';

class CaloriePercentagePreview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CaloriePercentagePreviewState();
}

class CaloriePercentagePreviewState extends State<CaloriePercentagePreview> with CardPart, CustomTextPart {
  static const double MIN_PERCENTAGE = 0.0;
  static const double MAX_PERCENTAGE = 100.0;

  static const BREAKFAST_INDEX = 0;
  static const DINNER_INDEX = 1;
  static const LAUNCH_INDEX = 2;
  static const EVENING_MEAL_INDEX = 3;
  static const SNACK_INDEX = 4;
  static const NIGHT_MEAL_INDEX = 5;

  List<int> percents = [20, 10, 20, 20, 20, 10];

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
          title: Text("Калораж"),
        ),
        body: SingleChildScrollView(
          child: createCard(
            Column(
              children: [
                _createSlider("Завтрак", BREAKFAST_INDEX, DINNER_INDEX),
                _createSlider("Обед", DINNER_INDEX, LAUNCH_INDEX),
                _createSlider("Полдник", LAUNCH_INDEX, EVENING_MEAL_INDEX),
                _createSlider("Ужин", EVENING_MEAL_INDEX, SNACK_INDEX),
                _createSlider("Перекус", SNACK_INDEX, NIGHT_MEAL_INDEX),
                _createSlider("Ночь", NIGHT_MEAL_INDEX, BREAKFAST_INDEX),
                SizedBox(height: 50.0),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: RawMaterialButton(
                    child: Text("Далее"),
                    padding: EdgeInsets.all(5.0),
                    fillColor: Colors.purple,
                    textStyle: TextStyle(color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            )
          ),
        )
      )
    );
  }

  Widget _createSlider(String name, int valueIndex, int affectValueIndex) {
    double percentValue = percents[valueIndex].roundToDouble();

    return Column(
      children: [
        Row(
          children: [
            createHeader(name),
            Spacer(),
            createHeader('${percentValue.round()}%'),
          ],
        ),
        Slider(
          activeColor: Colors.purple,
          value: percentValue,
          min: MIN_PERCENTAGE,
          max: MAX_PERCENTAGE,
          onChanged: (double value) =>
              setState(() =>
                  _calculatePercents(value.round(), valueIndex, affectValueIndex)),
        )
      ],
    );
  }

  _calculatePercents(int newValue, int valueIndex, int affectValueIndex) {
    int staticPercentSum = 0;
    for (int i = 0; i < percents.length; ++i) {
      if (i != affectValueIndex && i != valueIndex) {
        staticPercentSum += percents[i];
      }
    }

    int newAffectValue =
        MAX_PERCENTAGE.round() - staticPercentSum - newValue;

    if (newAffectValue < MIN_PERCENTAGE) {
      int error = MIN_PERCENTAGE.round() - newAffectValue;
      newAffectValue += error;
      newValue -= error;
    }

    if (newAffectValue > MAX_PERCENTAGE) {
      int error = newAffectValue - MAX_PERCENTAGE.round();
      newAffectValue -= error;
      newValue += error;
    }

    percents[valueIndex] = newValue;
    percents[affectValueIndex] = newAffectValue;
  }
}