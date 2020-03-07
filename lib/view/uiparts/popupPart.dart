import 'package:flutter/material.dart';

class PopupPart {
  Future createLoadingPopup(BuildContext context, bool isModal) {
    return showDialog(
      context: context,
      barrierDismissible: !isModal,
      child: AlertDialog(
        title: Text("Загрузка..."),
        content: SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator()
        ),
      )
    );
  }

  Future createWarningPopup(BuildContext context, String text) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        child: AlertDialog(
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.warning,
                  color: Colors.yellow[600],
                ),
              ),
              Text("Внимание!")
            ],
          ),
          content: Text(text),
          actions: [
            FlatButton(
              child: Text("Закрыть"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }

  Future createInputPopup(
      BuildContext context,
      String name,
      TextEditingController resultController,
      bool isModal) {
    TextEditingController controller = TextEditingController(
      text: resultController.text
    );

    return showDialog(
        context: context,
        barrierDismissible: !isModal,
        child: AlertDialog(
          title: Text(name),
          content: TextFormField(
            controller: controller,
          ),
          actions: [
            FlatButton(
              child: Text("Отменить"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Подтвердить"),
              onPressed: () {
                resultController.text = controller.text;
                Navigator.of(context).pop();
              },
            )
          ],
        ),
    );
  }

  Future<bool> createConfirmPopup(BuildContext context, String text) async {
    bool result = false;

    await showDialog(
        context: context,
        barrierDismissible: false,
        child: AlertDialog(
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.warning,
                  color: Colors.yellow[600],
                ),
              ),
              Text("Внимание!")
            ],
          ),
          content: Text(text),
          actions: [
            FlatButton(
              child: Text("Ок"),
              onPressed: () {
                result = true;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        )
      );

    return result;
  }
}