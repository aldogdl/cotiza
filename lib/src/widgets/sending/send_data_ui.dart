import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'circle_progress.dart';
import 'circle_progress_entity.dart';

class SendDataUi extends StatefulWidget {

  final ValueChanged<Map<String, dynamic>> onFinish;
  final ValueChanged<String> onChangeConnection;
  final CircleProgressEntity valoresProgress;
  final List<Widget> children;

  const SendDataUi({
    required this.children,
    required this.onFinish,
    required this.valoresProgress,
    required this.onChangeConnection,
    Key? key
  }) : super(key: key);

  @override
  State<SendDataUi> createState() => _SendDataUiState();
}

class _SendDataUiState extends State<SendDataUi> {

  final Globals globals = getSngOf<Globals>();
  String connx = 'DATOS';
  double bpw = 700.0;

  @override
  void initState() {

    // Esperamos se pinte el primer FRAME.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      connx = await globals.checkConnectivity();
      widget.onChangeConnection(connx);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double w = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            width: w,
            constraints: BoxConstraints(
              maxWidth: bpw
            ),
            child: (w >= bpw)
            ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: _ladoIzq(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: widget.children,
                  ),
                ),
              ],
            )
            : Column(
              children: [
                ..._ladoIzq(),
                ...widget.children
              ],
            )
          )
        )
      ),
    );
  }

  ///
  List<Widget> _ladoIzq() {

    double w = MediaQuery.of(context).size.width;
    Widget spa = const SizedBox(height: 20);

    return [
      spa,
      Text(
        'ENVIANDO INFORMACIÓN',
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: globals.styleText(19, Colors.blue, true)
      ),
      Text(
        'al Sistema Central de Procesamiento',
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: globals.styleText(15, Colors.grey, false)
      ),
      spa,
      if(w >= bpw)
        ...[
          CircleProgress(valores: widget.valoresProgress),
          spa,
        ],
      _msgConnection('Dependiendo del tamaño original de tus imágenes el proceso puede tardar unos segundos más. \nTen pasciencia por favor.'),
      spa,
      if(w < bpw)
        ...[
          CircleProgress(valores: widget.valoresProgress),
          spa,
        ]
      ];
  }

  ///
  Widget _msgConnection(String msg) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        msg,
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: globals.styleText(16, Colors.white, false)
      )
    );
  }

}