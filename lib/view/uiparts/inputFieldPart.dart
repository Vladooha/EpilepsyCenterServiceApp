import 'package:flutter/material.dart';

class InputFieldPart {
  Widget createTextField(
      BuildContext context,
      TextEditingController controller,
      String hint,
      {
        Icon icon,
        bool obscure = false,
        String error,
        bool hideErrorOnEmpty = true
      }) {
    Widget prefixIcon;
    if (icon != null) {
      prefixIcon = Padding(
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).primaryColor),
          child: icon,
        ),
        padding: EdgeInsets.only(left: 20, right: 10),
      );
    }

    if (hideErrorOnEmpty) {
      if (controller.text == null || controller.text == "") {
        error = null;
      }
    }

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            hintText: hint ?? "",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 3,
              ),
            ),
            prefixIcon: prefixIcon,
            errorText: error
          )
      ),
    );
  }

  Widget createFormTextField(
      Stream<String> valueStream,
      Function(String) valueValidator,
      String hint,
      {
        Icon icon,
        bool obscure = false,
        TextEditingController controller
      }) {
    controller ??= TextEditingController();
    controller.addListener(() => valueValidator(controller.text));
    controller.text = controller.text ?? "";
    controller.notifyListeners();

    return StreamBuilder<String>(
      initialData: controller.text,
      stream: valueStream,
      builder: (context, snapshot) {
        String error = snapshot.error?.toString();

        return createTextField(
            context,
            controller,
            hint,
            icon: icon,
            obscure: obscure,
            error: error);
      },
    );
  }
}