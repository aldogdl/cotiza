import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:flutter/material.dart';

class NoFoundUI extends StatelessWidget {

  NoFoundUI({Key? key}) : super(key: key);

  final Globals globals = getSngOf<Globals>();
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Text(
          ':( Pagina no econtrada',
          textScaleFactor: 1,
          style: globals.styleText(30, Colors.grey, true),
        ),
      ),
    );
  }
}