import 'package:flutter/material.dart';

class CardPart {
  Widget createCard(Widget child, {double padding = 10.0, radius = 10.0, elevation = 10.0}) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)
          ),
          elevation: elevation,
          child: child
      ),
    );
  }
}