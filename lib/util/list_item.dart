import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Widget ListItem(
String left,
Widget right,
Color? backgroundColor,
Color? textColor,)
{
  return Container(
    height: 50,
    color: backgroundColor,
    child: Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: TextStyle(color: textColor, fontSize: 16, height: 1), ),
          right
        ],
      ),
    ),
  );
}
