import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import '../../varios_widgets.dart';

class TitleAndActions extends StatelessWidget {

  final int totalMax;
  final int totCurrent;
  final String theme;
  final ValueChanged<String> onTap;
  TitleAndActions({
    required this.totalMax,
    required this.totCurrent,
    required this.onTap,
    this.theme = 'light',
    Key? key
  }) : super(key: key);

  final globals = getSngOf<Globals>();
  final VariosWidgets variosWidgets = VariosWidgets();
  
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Agregar Fotos: $totCurrent de $totalMax máximo',
            textScaleFactor: 1,
            style: globals.styleText(
              15,
              (theme == 'light') ? Colors.white : Colors.black,
              true
            )
          ),
          const Spacer(),
          if(totCurrent > 0)
            _btnsActions(context)
        ],
      ),
    );
  }

  ///
  Widget _btnsActions(BuildContext context) {

    return Row(
      children: [
        const SizedBox(width: 15),
        if(globals.isMobileDevice)
          ...[
            Tooltip(
              message: 'Tomar Fotográfia',
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () async {
                  if(totCurrent >= totalMax) {
                    await _showDialogAlert(context);
                    return;
                  }
                  onTap('camera');
                },
                child: const Icon(Icons.camera_alt, size: 25, color: Colors.grey),
              )
            ),
            const SizedBox(width: 20),
          ],
        Tooltip(
          message: 'Seleccionar Imagenes',
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: () async {
              if(totCurrent >= totalMax) {
                await _showDialogAlert(context);
                return;
              }
              onTap('galeria');
            },
            child: const Icon(Icons.snippet_folder_rounded, size: 30, color: Colors.amber),
          )
        ),
        const SizedBox(width: 10),
      ]
    );
  }

  ///
  Future<void> _showDialogAlert(BuildContext context) async => variosWidgets.dialog(
      cntx: context,
      tipo: 'entendido',
      icono: Icons.camera_roll_outlined,
      colorIcon: Colors.red,
      titulo: 'Haz Llegado al Máximo',
      textMain: 'Recuerda que sólo puedes enviar un máximo de $totalMax fotográfias.',
      textSec: 'Elimina las fotos que no necesites primeramente e inténtalo de nuevo.',
  );
}