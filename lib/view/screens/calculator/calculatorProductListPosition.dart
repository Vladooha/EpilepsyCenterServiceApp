import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/bloc/calculator/calculatorBloc.dart';
import 'package:frontend/bloc/calculator/calculatorBlocEvent.dart';
import 'package:frontend/model/calculator/product.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/uiparts/cardPart.dart';
import 'package:frontend/view/uiparts/popupPart.dart';

import 'calculatorProductView.dart';

class CalculatorProductListPosition extends StatelessWidget with CardPart, PopupPart {
  final CalculatorBloc calculatorBloc =
    BlocContainerService.instance.getAndInit(CalculatorBloc.BLOC_NAME);

  final Product product;
  Future<bool> Function(Product) onChoose;
  final bool editable;

  BuildContext context;

  CalculatorProductListPosition(this.product, {this.onChoose}) : editable = onChoose == null;

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return createCard(
        ListTile(
          title: Row(
            children: [
              Expanded(
                flex: 7,
                child: Text(product.name)
              ),
              Flexible(
                flex: 1,
                child: _createSubtaskButton(context),
              )
            ]
          ),
          onTap: () async {
            onChoose ??= _openProductView;

            bool isChosen = await onChoose.call(product);
            if (isChosen) {
              Navigator.of(context).pop();
            }
          },
        ),
        elevation: 5.0
    );
  }

  Widget _createSubtaskButton(BuildContext context) {
    if (onChoose != null) {
      return _createActionButton(
          Icons.search,
          () => _openProductView(product)
      );
    } else {
      return _createActionButton(
          Icons.delete,
          () => _deleteProduct(product)
      );
    }
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

  Future<bool> _openProductView(Product product) async {
    Navigator
        .of(context)
        .push(CalculatorProductViewRoute(product, editable: editable));

    return false;
  }

  _deleteProduct(Product product) async {
    String warningText = "Удаление продукта приведёт к удалению всех блюд, "
        "содержащих его! Хотите продолжить?";

    bool confirmed = await createConfirmPopup(context, warningText);

    if (confirmed) {
      calculatorBloc.eventListener.add(DeleteProduct(product.id));
    }
  }
}