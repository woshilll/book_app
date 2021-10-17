import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final double elevation;
  final Widget child;
  final double widthPercent;
  const CustomDrawer({
    Key? key,
    this.elevation = 16.0,
    required this.child,
    this.widthPercent = 0.7,
  })  : assert(
  widthPercent < 1.0 && widthPercent > 0.0),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final double _width = MediaQuery.of(context).size.width * widthPercent;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(width: _width),
        child: Material(
          elevation: elevation,
          child: child,
        ),
      ),
    );
  }
}
