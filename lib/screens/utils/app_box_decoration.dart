import 'package:flutter/material.dart';

BoxDecoration appBoxDecoration({Color brushColor = Colors.red}) {
  return BoxDecoration(
    color: Colors.red,
    gradient: LinearGradient(
      colors: [brushColor.withOpacity(.8), brushColor.withOpacity(.75), brushColor.withOpacity(.6)],
      begin: FractionalOffset.topRight,
      end: FractionalOffset.centerLeft,
    ),
  );
}
