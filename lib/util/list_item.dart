import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ListItem extends StatelessWidget {
  String left;
  Widget right;
  ListItem(this.left, this.right, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Theme.of(globalContext).textTheme.bodyText2!.color,
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left, style: TextStyle(color: Theme.of(globalContext).textTheme.bodyText1!.color, fontSize: 16, height: 1), ),
            right
          ],
        ),
      ),
    );
  }
}