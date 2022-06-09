import 'dart:io';

import 'package:camera/camera.dart' show CameraDescription;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show BuildContext, AlertDialog, Color,
showDialog, BoxConstraints, MediaQuery, Colors, TextStyle, FontWeight;
import 'package:breakpoint/breakpoint.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:autoparnet_cotiza/src/pages/user_reg/get_token_server.dart';

enum NotifPush { isOk, noCom, inError }

class Globals {

 CameraDescription? firstCamera;

  bool checkedStt = false;
  
  // El color de los status
  Color getColorStatus(int statusId) {

    Color colorSts = const Color(0xff3f3f3f);
    switch (statusId) {
      case 2:
        colorSts  = const Color(0xaa2196f3);
        break;
      case 3:
        colorSts  = const Color(0xff5FB131);
        break;
      case 4:
        colorSts  = Colors.blue[200]!;
        break;
      case 5:
        colorSts  = Colors.blueAccent;
        break;
      case 8:
        colorSts  = Colors.yellow[300]!;
        break;
      case 9:
        colorSts  = Colors.yellow;
        break;
      case 10:
        colorSts  = Colors.red;
        break;
      default:
    }
    return colorSts;
  }

  // Con esta comprobamos que ya se hizo la prueba de comunicacion push en el home
  bool hasPruebaDeCom = false;

  // Utilizada para evitar enviar varias veces el push al SCP de que el
  // usuario a leido las repuestas.
  List<int> idsRepoLeida = [];
  // Usada para pasar el status devuelto por el server cuando se hace un pedido
  int statusPedida = 0;
  int idUser = 0;
  final colors = <String, dynamic> {
    'greenMain': Colors.green,
    'blackLigt': Colors.black87
  };
  
  final int maxWidthToFotos = 768;
  final double minH = 430;
  final double minW = 300;
  final double maxIzq = 400;
  final double minIzq = 320;
  final double tabletMax = 841;
  final double tabletMin = 650;

  double getMaxWidht(BoxConstraints constraints) {
    String bp = getDeviceFromConstraints(constraints);
    return (bp != 'mediumHandset') ? maxIzq : constraints.maxWidth;
  }
  
  ///
  double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Mostramos la parte de los outlet en HOME
  ValueNotifier<bool> showOutlet = ValueNotifier(true);

  ///
  TextStyle styleText(double size, Color color, bool isBold, {double sw = 0}) {

    return TextStyle(
      color: color,
      fontSize: size,
      letterSpacing: sw,
      fontWeight: (isBold) ? FontWeight.bold :  FontWeight.normal
    );
  }

  ///
  bool get isMobileDevice => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  bool get isDesktopDevice =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  bool get isMobileDeviceOrWeb => kIsWeb || isMobileDevice;
  bool get isDesktopDeviceOrWeb => kIsWeb || isDesktopDevice;
  bool get isWeb => kIsWeb;
  //etc

  ///
  Breakpoint bpFromMediaQuery(BuildContext context) {
    return Breakpoint.fromMediaQuery(context);
  }
  
  ///
  String getDataFromMediaQueryBasic(BuildContext context) {
    final breakpoint = bpFromMediaQuery(context);
    final maxWidth = MediaQuery.of(context).size.width;
    return 'Main: ${breakpoint.device}, Witdh: $maxWidth.';
  }

  ///
  String getDataFromMediaQueryFull(BuildContext context) {
    final breakpoint = bpFromMediaQuery(context);
    final maxWidth = MediaQuery.of(context).size.width;
    return '''
  Main: ${breakpoint.device}, Witdh: $maxWidth,
  Cols: ${breakpoint.columns}, Sp: ${breakpoint.gutters}
  Tipo: $breakpoint
    ''';
  }

  ///
  Breakpoint bpFromConstraints(BoxConstraints constraints) {
    return Breakpoint.fromConstraints(constraints);
  }

  ///
  String getDeviceFromMediaQuery(BuildContext context) {

    return getDevices(Breakpoint.fromMediaQuery(context));
  }

  ///
  String getDeviceFromConstraints(BoxConstraints constraints) {

    return getDevices(Breakpoint.fromConstraints(constraints));
  }

  ///
  String getDevices(Breakpoint bp) {

    late String device;

    switch (bp.device){
      case LayoutClass.smallHandset:
        device = 'mediumHandset';
        break;
      case LayoutClass.mediumHandset:
        device = 'mediumHandset';
        break;
      case LayoutClass.largeHandset:
        device = 'largeTablet';
        break;
      case LayoutClass.smallTablet:
        device = 'largeTablet';
        break;
      case LayoutClass.largeTablet:
        device = 'largeTablet';
        break;
      case LayoutClass.desktop:
        device = 'largeTablet';
        break;
      default:
    }

    return device;
  }

  ///
  String getDataFromConstraintsBasic(BoxConstraints constraints) {
    final breakpoint = bpFromConstraints(constraints);
    return 'Main: ${breakpoint.device}, Witdh: ${constraints.maxWidth}.';
  }

  ///
  String getDataFromConstraintsFull(BoxConstraints constraints) {
    final breakpoint = bpFromConstraints(constraints);
    return 'Main: ${breakpoint.device}, Tipo: $breakpoint Cols: ${breakpoint.columns}, Sp: ${breakpoint.gutters}';
  }

  ///
  Future<String> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return 'DATOS';
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return 'WIFI';
    }
    return '';
  }

  ///
  Future<void> refreshTokenServer({
    required BuildContext context,
    required ValueChanged<void> onRefresh
  }) async {

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: GetTokenServer(
          onSaveToken: (_) => onRefresh(null)
        ),
      )
    );
  }
}
