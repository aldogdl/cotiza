import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';

class VariosWidgets {

  final Globals globals = getSngOf<Globals>();
  final RefCotiz refCotiz = getSngOf<RefCotiz>();
  BuildContext? contextOnClose;

  ///
  void message({
    required BuildContext context,
    required String msg,
    Color bg = Colors.green,
    Color fg = Colors.black,
  }) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bg,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            msg,
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: fg,
              fontWeight: FontWeight.bold
            )
          )
        )
      ),
    );
  }

  ///
  Future<bool?> dialog({
    required BuildContext cntx,
    required String tipo,
    required IconData icono,
    required Color colorIcon,
    required String titulo,
    required String textMain,
    String textSec = '',
    bool isFix = false
  }) async {

    return await showDialog(
      context: cntx,
      barrierDismissible: isFix,
      builder: (context) => _getDialogType(
        context, tipo, titulo, icono, colorIcon, textMain, textSec
      )
    );
  }

  ///
  Widget _getDialogType(
    BuildContext context,
    String tipo, String titulo, IconData icono, Color colorIcono,
    String textMain, String textSec
  ) {
    
    Widget acciones = _getAccionesByTipo(context, tipo);

    switch (tipo) {
      case 'entendido': return _dialogFinal(
        titulo, icono, colorIcono, textMain, textSec, acciones
      );
      case 'yesOrNot': return _dialogFinal(
        titulo, icono, colorIcono, textMain, textSec, acciones
      );
      case 'loading': {
        contextOnClose = context;
        return _dialogFinal(
          titulo, icono, colorIcono, textMain, textSec, acciones
        );
      } 
      default: 
        return const Text('No se encontro ningún Aviso');
    }
  }

  ///
  Widget _dialogFinal(
    String titulo, IconData icono, Color colorIcono, String textMain,
    String textSec, Widget acciones
  ) {

    return AlertDialog(
      title: _titulo(titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icono, size: 50, color: colorIcono),
          const SizedBox(height: 10),
          Text(
            textMain,
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: globals.styleText(15, Colors.black, false),
          ),
          const SizedBox(height: 5),
          Text(
            textSec,
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: globals.styleText(15, Colors.grey, false),
          ),
          const SizedBox(height: 10),
          acciones
        ]
      ),
    );
  }

  ///
  Widget _titulo(String titulo) {

    return Text(
      titulo,
      textScaleFactor: 1,
      style: globals.styleText(17, Colors.orange, true),
    );
  }

  ///
  Widget _getAccionesByTipo(BuildContext context, String tipo) {

    switch (tipo) {
      case 'yesOrNot': return _btnYesOrNot(context);
      case 'loading': return const LinearProgressIndicator();
      default: return _btnEntendido(context);
    }
  }

  ///
  Widget _btnYesOrNot(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btn(' SI ', () => Navigator.of(context).pop(true)),
        _btn(' NO ', () => Navigator.of(context).pop(false)),
      ],
    );
  }

  ///
  Widget _btnEntendido(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn('ENTENDIDO', () => Navigator.of(context).pop(false))
      ],
    );
  }

  ///
  Widget _btn(String txt, Function acc) {

    return OutlinedButton(
      onPressed: () => acc(),
      child: Text(
        txt,
        textScaleFactor: 1,
        style: globals.styleText(16, Colors.green, false),
      ),
    );
  }


}