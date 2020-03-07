import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/view/uiparts/popupPart.dart';

class TablePart {
  PopupPart popupPart = PopupPart();
  
  Table createTable(List<TableRow> children) {
    return Table(
      children: children,
    );
  }

  TableRow createTableRowDivider() {
    return TableRow(
        children: [
          Divider(color: Colors.grey,)
        ]
    );
  }

  TableRow createTableRow<T>(
      String name,
      {T value}) {
    String currentValue = value != null ? value.toString() : "";
    List<Widget> columns = [];
    _addDefaultColumns(columns, name, currentValue);

    return TableRow(
        children: [
          GestureDetector(
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: columns,
                ),
              )
          )
        ]);
  }

  TableRow createEditableTableRow<T>(
      String name,
      T Function() valueGetter,
      void Function(T) valueSetter,
      BuildContext context,
      void Function(void Function()) stateUpdater) {
    String currentValue = _parseGetter(valueGetter);
    List<Widget> columns = [];
    _addDefaultColumns(columns, name, currentValue);

    _addEditIconColumn(columns);

    return TableRow(
        children: [
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: columns,
              ),
            ),
            onTap: () {
              _editRow(valueSetter, name, currentValue, context, stateUpdater);
            }
          )
        ]);
  }

  String _parseGetter<T>(T Function() valueGetter) {
    String currentValue = "";
    if (valueGetter != null) {
      T value = valueGetter.call();
      currentValue = value.toString();
    }

    return currentValue;
  }

  List<Widget> _addDefaultColumns(
      List<Widget> columns,
      String name,
      String currentValue) {

    columns.addAll([
      Text(name),
      Spacer(),
      Text(currentValue)
    ]);

    return columns;
  }

  List<Widget> _addEditIconColumn(List<Widget> columns) {
    columns.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Icon(
            Icons.edit,
            size: 16.0,
          ),
        )
    );

    return columns;
  }

  _editRow<T>(
      Function(T) valueSetter,
      String name,
      String currentValue,
      BuildContext context,
      void Function(void Function()) stateUpdater) async {
    if (valueSetter != null) {
      String newValue = await _getValueFromPopup(name, currentValue, context);
      bool isUpdateSuccess =
        _updateFieldWithSetter(newValue, valueSetter, stateUpdater);
      if (!isUpdateSuccess && context != null) {
        popupPart.createWarningPopup(context, "Введено неверное значение");
      }
    }
  }

  Future<String> _getValueFromPopup(
      String fieldName,
      String currentValue,
      BuildContext context) async {
    TextEditingController controller = TextEditingController();
    controller.text = currentValue;
    await popupPart.createInputPopup(context, fieldName, controller, true);

    return controller.text;
  }

  bool _updateFieldWithSetter<T>(
      String newValue,
      void Function(T) valueSetter,
      void Function(void Function()) stateUpdater) {
    String runtimeType = T.toString();

    try {
      switch (runtimeType) {
        case "int":
          valueSetter.call(int.parse(newValue) as T);
          break;
        case "double":
          valueSetter.call(double.parse(newValue) as T);
          break;
        case "String":
          valueSetter.call(newValue as T);
          break;
        default:
          print('Type $runtimeType isn\'t supported by table');
          break;
      }

      stateUpdater.call(() {});

      return true;
    } catch(e) {
      return false;
    }
  }
}