import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/bloc/calculator/calculatorBloc.dart';
import 'package:frontend/bloc/calculator/calculatorBlocEvent.dart';
import 'package:frontend/model/calculator/product.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/uiparts/cardPart.dart';
import 'package:frontend/view/uiparts/customTextPart.dart';
import 'package:frontend/view/uiparts/drawerMenuPart.dart';
import 'package:frontend/view/uiparts/inputFieldPart.dart';
import 'package:frontend/view/uiparts/popupPart.dart';
import 'package:frontend/view/uiparts/tablePart.dart';

class CalculatorProductView extends StatefulWidget {
  final CalculatorBloc calculatorBloc =
    BlocContainerService.instance.getAndInit(CalculatorBloc.BLOC_NAME);

  final Product product;
  final bool editable;
  final bool isNewProduct;
  final TextEditingController nameController = TextEditingController();

  CalculatorProductView(this.product, {editable = false, this.isNewProduct = false})
      : this.editable = editable || isNewProduct;

  @override
  State<StatefulWidget> createState() => CalculatorProductViewState();
}

class CalculatorProductViewState extends State<CalculatorProductView>
    with DrawerMenuPart, TablePart, CardPart, CustomTextPart, InputFieldPart, PopupPart {
  double customWeight = 10.0;

  @override
  Widget build(BuildContext context) {
    String viewName = widget.isNewProduct
        ? "Информация о продукте"
        : "Добавление продукта";

    return Scaffold(
      appBar: AppBar(
          title: Text(viewName)
      ),
      drawer: createDrawerMenuPart(context),
      body: _createBody()
    );
  }

  Widget _createBody() {
    List<Widget> children = [];

    if (widget.isNewProduct) {
      var nameInputField = Padding(
        padding: EdgeInsets.all(5.0),
//        child: createInputTextField(
//            "Название",
//            widget.nameController,
//            _validateProductName
//        )
      );

      children.addAll([
        nameInputField,
        _createTable(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: _createSaveButton()
            )
          ]
        ),
      ]);
    } else {
      children.addAll([
        createHeader(widget.product.name),
        _createTable()
      ]);
    }

    return createCard(
        SingleChildScrollView(
          padding: EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        )
    );
  }

  Widget _createTable() {
    List<TableRow> tableRows = [];

    Product product = widget.product;

    if (widget.editable) {
      tableRows.addAll([
        createTableRow("На 100 грамм: "),
        createTableRowDivider(),
        createEditableTableRow("Белки", product.getProteins, product.setProteins, context, setState),
        createEditableTableRow("Жиры", product.getFats, product.setFats, context, setState),
        createEditableTableRow("Углеводы", product.getCarbohydrates, product.setCarbohydrates, context, setState),
        createTableRowDivider(),
        createEditableTableRow("Холестерин", product.getCholesterol, product.setCholesterol, context, setState),
        createEditableTableRow("Натрий", product.getSodium, product.setSodium, context, setState),
        createEditableTableRow("Балластные вещ-ва", product.getBallast, product.setBallast, context, setState),
        createTableRowDivider(),
        createEditableTableRow("В рассчёте на вес: ", _getCustomWeight, _setCustomWeight, context, setState),
        createTableRowDivider(),
        createEditableTableRow("Белки", _customGetter(product.getProteins), _customSetter(product.setProteins), context, setState),
        createEditableTableRow("Жиры", _customGetter(product.getFats), _customSetter(product.setFats), context, setState),
        createEditableTableRow("Углеводы", _customGetter(product.getCarbohydrates), _customSetter(product.setCarbohydrates), context, setState),
        createTableRowDivider(),
        createEditableTableRow("Холестерин", _customGetter(product.getCholesterol), _customSetter(product.setCholesterol), context, setState),
        createEditableTableRow("Натрий", _customGetter(product.getSodium), _customSetter(product.setSodium), context, setState),
        createEditableTableRow("Балластные вещ-ва", _customGetter(product.getBallast), _customSetter(product.setBallast), context, setState),
      ]);
    } else {
      tableRows.addAll([
        createTableRow("На 100 грамм: "),
        createTableRowDivider(),
        createTableRow("Белки", value: product.getProteins()),
        createTableRow("Жиры", value: product.getFats()),
        createTableRow("Углеводы", value: product.getCarbohydrates()),
        createTableRowDivider(),
        createTableRow("Холестерин", value: product.getProteins()),
        createTableRow("Натрий", value: product.getFats()),
        createTableRow("Балластные вещ-ва", value: product.getCarbohydrates()),
        createTableRowDivider(),
        createEditableTableRow("В рассчёте на вес: ", _getCustomWeight, _setCustomWeight, context, setState),
        createTableRowDivider(),
        createTableRow("Белки", value: product.getProteins(weight: customWeight)),
        createTableRow("Жиры", value: product.getFats(weight: customWeight)),
        createTableRow("Углеводы", value: product.getCarbohydrates(weight: customWeight)),
        createTableRowDivider(),
        createTableRow("Холестерин", value: product.getProteins(weight: customWeight)),
        createTableRow("Натрий", value: product.getFats(weight: customWeight)),
        createTableRow("Балластные вещ-ва", value: product.getCarbohydrates(weight: customWeight)),
      ]);
    }

    return createTable(tableRows);
  }

  Widget _createSaveButton() {
    return RawMaterialButton(
      padding: EdgeInsets.all(10.0),
      child: Text("Сохранить"),
      textStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.grey[150]
      ),
      fillColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)
      ),
      onPressed: _validateAndSaveProduct,
    );
  }

  double _getCustomWeight() => customWeight;

  _setCustomWeight(double value) => customWeight = value;

  double Function() _customGetter(double Function({double weight}) getter) {
    return () => getter.call(weight: customWeight);
  }

  void Function(double) _customSetter(void Function(double, {double weight}) setter) {
    return (value) => setter.call(value, weight: customWeight);
  }

  _validateAndSaveProduct() {
    String productName = widget.nameController.text;
    List<String> errorList = _validateProductName(productName);

    if (errorList != null && errorList.isEmpty) {
      widget.product.name = productName;

      _saveProduct();

      Navigator.of(context).pop();
    } else {
      createWarningPopup(context, errorList[0]);
    }
  }

  List<String> _validateProductName(String name) {
    return [];
  }

  _saveProduct() {
    widget.calculatorBloc.eventListener.add(AddProduct(widget.product));
  }
}

class CalculatorProductViewRoute extends CupertinoPageRoute {
  CalculatorProductViewRoute(Product product, {bool editable = false, bool isNewProduct = false})
      : super(builder: (BuildContext context)
        => CalculatorProductView(
            product,
            editable: editable,
            isNewProduct: isNewProduct)
          );
}