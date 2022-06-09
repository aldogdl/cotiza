import 'package:flutter/material.dart';

class IcoFotoFrom extends StatelessWidget {

  final IconData icono;
  final String label;
  final Color colorLabel;
  const IcoFotoFrom({
    required this.icono,
    required this.label,
    this.colorLabel = Colors.black,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icono, color: (label != 'GALERÍA') ? Colors.black : Colors.amber),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textScaleFactor: 1,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorLabel,
            fontSize: 14
          )
        )
      ],
    );
  }
}