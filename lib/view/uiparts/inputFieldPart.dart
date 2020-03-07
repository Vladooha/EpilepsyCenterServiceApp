import 'package:flutter/material.dart';

class InputFieldPart {
  Widget createInputTextField(
      String name,
      TextEditingController controller,
      List<String> validator(String textValue),
      {
        bool isRequired,
        bool isPassword,
      }) {
    return SizedBox (
        height: 80,
        child: TextFormField(
          controller: controller,
          validator: (value) {
            List<String> errors = validator(value);
            if (errors == null || errors.isEmpty) {
              return null;
            } else {
              return errors[0];
            }
          },
          obscureText: isPassword != null && isPassword,
          style: TextStyle(
            fontSize: 18,
          ),
          decoration: InputDecoration(
            focusColor: Colors.white,
            labelText: name + (isRequired ?? false ? " *" : ""),
            labelStyle: TextStyle(
              fontSize: 20,
            ),
          ),
        )
    );
  }
}