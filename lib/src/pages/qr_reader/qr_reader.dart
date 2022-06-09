import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../widgets/varios_widgets.dart';

class QrReader extends StatefulWidget {

  final ValueChanged<Map<String, String?>> onReaded;
  const QrReader({
    required this.onReaded,
    Key? key
  }) : super(key: key);

  @override
  State<QrReader> createState() => _QrReaderState();
}

class _QrReaderState extends State<QrReader> {

  final VariosWidgets variosWidgets = VariosWidgets();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // Para la recarga en caliente
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }
  
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  ///
  Future<void> _onQRViewCreated(QRViewController controller) async {

    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {

      controller.stopCamera().then((_) {
        
        variosWidgets.message(
          context: context, msg: 'EL CÓDIGO HA SIDO LEIDO :)'
        );
        
        Future.delayed(const Duration(seconds: 1), (){
          if(mounted) {
            Navigator.of(context).pop();
          }
          widget.onReaded({
            'format' : describeEnum(scanData.format),
            'code'   : scanData.code
          });
        });
      });
    });
  }
}