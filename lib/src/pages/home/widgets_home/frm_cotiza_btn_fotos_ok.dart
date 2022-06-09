import 'package:flutter/material.dart';

class FrmCotizaBtnFotosOk extends StatelessWidget {

  final int cantFotos;
  final int idOrden;
  final TextStyle btnStyleListo;
  final bool showBtnVerPiezas;
  final TextStyle btnStyleVerPiezas;
  final ValueChanged<void> onPressBtnVerPiezas;
  final ValueChanged<void> onPressBtnListo;
  const FrmCotizaBtnFotosOk({
    Key? key,
    required this.cantFotos,
    required this.idOrden,
    required this.btnStyleListo,
    required this.showBtnVerPiezas,
    required this.btnStyleVerPiezas,
    required this.onPressBtnVerPiezas,
    required this.onPressBtnListo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double s = MediaQuery.of(context).size.width;
    double w = s * 0.8;

    return SizedBox(
      width: s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: w,
            child: ElevatedButton(
              onPressed: () => onPressBtnListo(null),
              child: Text(
                '¡Listo!, continuar con el registro',
                textScaleFactor: 1,
                style: btnStyleListo
              )
            ),
          ),
          const SizedBox(height: 20),
          if(showBtnVerPiezas)
            SizedBox(
              width: w,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10))
                ),
                onPressed: () => onPressBtnVerPiezas(null),
                child: Text(
                  (cantFotos > 1)
                    ? 'Ver las $cantFotos Piezas de la Orden $idOrden'
                    : 'Ver la Pieza de la orden $idOrden',
                  textScaleFactor: 1,
                  style: btnStyleVerPiezas
                )
              ),
            )
        ],
      ),
    );
  }
}