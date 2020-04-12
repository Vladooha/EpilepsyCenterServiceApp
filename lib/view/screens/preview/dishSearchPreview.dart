import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/calculator/dish.dart';
import 'package:frontend/model/calculator/product.dart';
import 'package:frontend/view/uiparts/cardPart.dart';

class DishSearchPreview extends StatelessWidget with CardPart {
  List<Dish> dishStubs = [
    Dish("1", Product("1", name: "Молоко", proteins: 50, fats: 50, carbohydrates: 50)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
    Dish("2", Product("1", name: "Хлопья", proteins: 30, fats: 70, carbohydrates: 5)),
  ];

  List<String> categories = [
    "Масла", "Выпечка", "Молочные продукты"
  ];

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
            title: Text("Добавить блюдо"),
          ),
          body: Column(
              children: [
                _createSearchRow(),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: false,
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
                  child: Text("Назад"),
                  onPressed: () {},
                ),
              ]
          ),
        )
    );
  }

  _createSearchRow() {
    return createCard(
      ExpansionTile(
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.0),
          child: TextField(
            onChanged: (value) {
//              setState(() {
//                query = widget.searchController.text;
//              });
            },
            controller: TextEditingController(),
            decoration: InputDecoration(
              labelText: "Поиск",
              hintText: "Поиск",
              prefixIcon: Icon(Icons.search),
              enabledBorder: null,
              focusedBorder: null,
              border: null,
//              border: OutlineInputBorder(
//                  borderRadius: BorderRadius.all(Radius.circular(15.0))
//              )
            ),
          ),
        ),
        trailing: Icon(Icons.menu),
        initiallyExpanded: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "Категории",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold
                  )
                )
              ),
              Spacer(),
              MaterialButton(
                child: Text("Очистить"),
                textTheme: ButtonTextTheme.accent,
                onPressed: () {},
              ),
              MaterialButton(
                child: Text("Выбрать все"),
                textTheme: ButtonTextTheme.accent,
                onPressed: () {},
              )
            ]
          ),
          _createCategoriesRow()
        ],
      ),
      padding: 5.0
    );
  }

  Widget _createCategoriesRow() {
    return Row(
        children: [
          _createIcon(Icons.arrow_back_ios),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: categories
                      .map(_createCategoryButton)
                      .map((button) =>
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: button))
                      .toList()
              ),
            ),
          ),
          _createIcon(Icons.arrow_forward_ios),
        ]
    );
  }

  Widget _createIcon(IconData iconData, {width = 30.0, height = 30.0, iconSize = 15.0}) {
    return IconButton(
      constraints: BoxConstraints.loose(Size(width, height)),
      iconSize: iconSize,
      icon: Icon(iconData),
      color: Colors.grey[150],
    );
  }

  Widget _createCategoryButton(String name) {
    return MaterialButton(
      color: name == "Выпечка" ? Colors.purple : Colors.grey,
      child: Text(name),
      onPressed: () {},
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
          trailing: Icon(Icons.add),
        ),
        padding: 5.0,
        elevation: 3.0
    );
  }
}