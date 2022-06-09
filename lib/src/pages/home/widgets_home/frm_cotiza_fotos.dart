import 'package:flutter/material.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'frm_cotiza_txt_fotos.dart';
import 'frm_cotiza_btn_fotos_ok.dart';
import '../../../widgets/get_fotos/singleton/picker_pictures.dart';
import '../../../widgets/get_fotos/get_fotos_widget.dart';

class FrmCotizaFotos extends StatelessWidget {

  final Widget sp;
  final int cantFotos;
  final int idOrden;
  final Globals globals;
  final String brackPoint;
  final bool showBtnVerPiezas;
  final ValueChanged<void> onPressBtnVerPiezas;
  final ValueChanged<void> onPressBtnListo;
  final PickerPictures picktures;
  final BoxConstraints constraints;

  const FrmCotizaFotos({
    Key? key,
    required this.sp,
    required this.cantFotos,
    required this.idOrden,
    required this.globals,
    required this.brackPoint,
    required this.showBtnVerPiezas,
    required this.onPressBtnVerPiezas,
    required this.onPressBtnListo,
    required this.picktures,
    required this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double sizeTitulo = (brackPoint != 'mediumHandset') ? 15 : 19;
    double sizeParafo = (brackPoint != 'mediumHandset') ? 14 : 17;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: (brackPoint == 'mediumHandset') ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FrmCotizaTxtFotos(
            styleTitulo: globals.styleText(sizeTitulo, Colors.green, false),
            styleParrafo: globals.styleText(sizeParafo, Colors.grey, false)
          ),
          sp,
          Center(
            child: Text(
              'INSTRUCCIONES:',
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: globals.styleText(15, Colors.green, false),
            ),
          ),
          const SizedBox(height: 8),
          ..._instFotosInMobile(),
          const SizedBox(height: 15),
          Center(
            child: GetFotosWidget(
              cantMax: picktures.maxPermitidas,
              theme: 'light',
              idOrden: idOrden,
              constraints: constraints,
              onFinish: (imgs){},
            ),
          ),
          sp,
          FrmCotizaBtnFotosOk(
            cantFotos: cantFotos,
            idOrden: idOrden,
            showBtnVerPiezas: showBtnVerPiezas,
            btnStyleListo: globals.styleText(
              (brackPoint == 'mediumHandset') ? 18 : 15,
              Colors.white, false
            ),
            btnStyleVerPiezas: globals.styleText(
              (brackPoint == 'mediumHandset') ? 18 : 15,
              Colors.white, false
            ),
            onPressBtnListo: onPressBtnListo,
            onPressBtnVerPiezas: onPressBtnVerPiezas
          )
        ],
      ),
    );
  }

  /// Instrucciones
  List<Widget> _instFotosInMobile() {

    return [
      Text.rich(
        TextSpan(
          text: 'CÁMARA: ',
          style: const TextStyle(
            color: Colors.white
          ),
          children: [
            TextSpan(
              text: 'Si presionas el icono de la cámara podrás tomar directamente '
              'las fotografías de la refacción solicitada.',
              style: globals.styleText(17, Colors.grey, false),
            )
          ]
        ),
        textScaleFactor: 1,
      ),
      const SizedBox(height: 25),
      Text.rich(
        TextSpan(
          text: 'GALERÍA: ',
          style: const TextStyle(
            color: Colors.white
          ),
          children: [
            TextSpan(
              text: 'En caso de contar con ellas previamente, selecciónalas desde '
              'el icono de la galería.',
              style: globals.styleText(17, Colors.grey, false),
            )
          ]
        ),
        textScaleFactor: 1,
      ),
    ];
  }

}