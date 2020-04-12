import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/model/calculator/dish.dart';
import 'package:frontend/model/calculator/eatingType.dart';
import 'package:frontend/model/calculator/nutrient.dart';
import 'package:frontend/model/calculator/product.dart';
import 'package:frontend/view/uiparts/cardPart.dart';
import 'package:frontend/view/uiparts/tablePart.dart';

import 'dailyRationPreview.dart';

class DishListPreview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DishListPreviewState();
}

class DishListPreviewState extends State<DishListPreview> with CardPart, TablePart {
  List<Dish> dishStubs = [
    Dish("1", Product("1", name: "Молоко", proteins: 50, fats: 50, carbohydrates: 50)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
  ];

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
          title: Text("Завтрак"),
        ),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                children: [
                  Checkbox(value: true, onChanged: (value) {}),
                  Text("Запомнить рецепт")
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  fillColor: Colors.purple,
                  labelText: "Название рецепта"
                ),
                controller: TextEditingController(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: dishStubs.length,
                itemBuilder: (context, index) {
                  return _createDishPosition(dishStubs[index]);
                }
              ),
            ),
            MaterialButton(
              minWidth: 100.0,
              color: Colors.purple,
              textColor: Colors.grey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  Text("Добавить блюдо")
                ],
              ),
              onPressed: () {},
            ),
            Padding(padding: EdgeInsets.all(5.0), child: _createTable()),
            _createButtons()
          ]
        ),
      )
    );
  }

  Widget _createDishPosition(Dish dish) {
    var protFatsCarbTotal = RichText(
        text: TextSpan(
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(text: "Б: "),
              TextSpan(text: '${dish.proteins.round()} '),
              TextSpan(text: "Ж: "),
              TextSpan(text: '${dish.fats.round()} '),
              TextSpan(text: "У: "),
              TextSpan(text: '${dish.carbohydrates.round()} '),
            ]
        )
    );

    return createCard(
        ListTile(
          title: Text(dish.name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: protFatsCarbTotal,
          trailing: SizedBox(
            width: 160.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Масса",
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.add, color: Colors.green)),
                Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.remove, color: Colors.red)),
                Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.delete)),
              ]
            ),
          ),
//          children: <Widget>[
//            Padding(
//              padding: EdgeInsets.all(10.0),
//              child: Row(
//                mainAxisSize: MainAxisSize.min,
//                children: [
//                  Expanded(
//                    child: TextField(
//                      decoration: InputDecoration(
//                        labelText: "Масса",
//                      ),
//                    ),
//                  ),
//                  Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.add, color: Colors.green)),
//                  Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.remove, color: Colors.red)),
//                ]
//              ),
//            )
//          ],
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