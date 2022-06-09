import 'package:flutter/material.dart';

class FrmCotizaTxtFotos extends StatelessWidget {

  final TextStyle styleTitulo;
  final TextStyle styleParrafo;
  const FrmCotizaTxtFotos({
    Key? key,
    required this.styleTitulo,
    required this.styleParrafo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            '¿POR QUÉ IMPORTAN LAS FOTOS?',
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: styleTitulo,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SOMOS MÁS DE 100 PROVEEDORES con perspectivas diferentes. '
          '"La foto nos orienta para otorgarte un mejor servicio".',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: styleParrafo,
        ),
      ],
    );
  }
}