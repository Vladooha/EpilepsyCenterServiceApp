import 'package:flutter/widgets.dart';

class CustomTextPart {
  Widget createHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0
        ),
      ),
    );
  }
}