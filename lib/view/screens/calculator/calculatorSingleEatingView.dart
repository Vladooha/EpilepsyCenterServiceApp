import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/model/calculator/dish.dart';
import 'package:frontend/model/calculator/product.dart';
import 'package:frontend/view/screens/calculator/calculatorProductView.dart';
import 'package:frontend/view/uiparts/cardPart.dart';
import 'package:frontend/view/uiparts/inputFieldPart.dart';
import 'package:frontend/view/uiparts/popupPart.dart';
import 'package:frontend/view/uiparts/tablePart.dart';

class CalculatorSingleEatingView extends StatefulWidget {
  final Dish dish;
  final Function onDishDelete;

  CalculatorSingleEatingView(this.dish, this.onDishDelete);

  @override
  State<StatefulWidget> createState() =>
      CalculatorSingleEatingViewState();
}

class CalculatorSingleEatingViewState extends State<CalculatorSingleEatingView>
    with PopupPart, TablePart, CardPart {

  @override
  Widget build(BuildContext context) {
    return createCard(
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: _createPositionHeader(widget.dish.product),
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.0),
          children: [
            Padding(
              padding: EdgeInsets.all(5.0),
              child: _createProductTable(widget.dish),
            )
          ],
        )
      ),
      padding: 5.0,
      radius: 20.0,
      elevation: 3.0
    );
  }



  Widget _createPositionHeader(Product product) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 6,
          child: Text(
              '${product.name}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14.0
              )
          ),
        ),
        Flexible(
          flex: 1,
          child: _createActionButton(Icons.search, () => _openProductEdition(product)),
        ),
        SizedBox(width: 5.0),
        Flexible(
          flex: 1,
          child: _createActionButton(Icons.delete, widget.onDishDelete)
        )
      ]
    );
  }



  Widget _createProductTable(Dish dish) {
    return createTable([
      createTableRow(dish.name),
      createTableRowDivider(),
      createTableRow("Белки", value: dish.proteinsSummary),
      createTableRow("Жиры", value: dish.fatsSummary),
      createTableRow("Углеводы", value: dish.carbohydratesSummary),
      createTableRowDivider(),
      createEditableTableRow<double>(
        "Масса (г)",
        dish.getWeight,
        dish.setWeight,
        context,
        setState
      )
    ]);
  }

  Widget _createActionButton(IconData iconData, Function() action) {
    return SizedBox(
      width: 32.0,
      height: 32.0,
      child: RawMaterialButton(
        onPressed: () => action.call(),
        child: Icon(
          iconData,
          color: Colors.grey,
          size: 20.0,
        ),
        shape: CircleBorder(),
        elevation: 2.0,
        fillColor: Colors.white,
      )
    );
  }
  
  _openProductEdition(Product product) {
    Navigator
        .of(context)
        .push(CalculatorProductViewRoute(product, editable: false));
  }
}