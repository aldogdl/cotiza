import 'package:flutter/material.dart';

import 'widgets_home/lienzo_content.dart';

class ChangePageUi extends StatelessWidget {
  
  final BoxConstraints constraints;
  const ChangePageUi({
    required this.constraints,
    Key? key
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    
    return LienzoContent(
      constraints: constraints,
      child: const Center(
        child: Icon(
          Icons.change_circle_outlined,
          size: 500,
          color: Color.fromARGB(255, 240, 240, 240)
        ),
      )
    );
  }
}