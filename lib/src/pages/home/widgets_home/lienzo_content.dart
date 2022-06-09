import 'package:flutter/material.dart';

class LienzoContent extends StatelessWidget {

  final Widget child;
  final BoxConstraints constraints;
  const LienzoContent({
    required this.constraints,
    required this.child,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight * 0.935,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5)
        )
      ),
      child: child
    );
  }
}