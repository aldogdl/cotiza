import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'login_frm_izq.dart';
import 'login_ui_der.dart';

class UserLoginUi extends StatefulWidget {

  const UserLoginUi({Key? key}) : super(key: key);

  @override
  State<UserLoginUi> createState() => _UserLoginUiState();
}

class _UserLoginUiState extends State<UserLoginUi> {

  final globals = getSngOf<Globals>();
  String _bp = '';
  double _maxH = 0.0;
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (_, constraints) {

            _bp = globals.getDeviceFromConstraints(constraints);
            _maxH = globals.getHeight(context);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(
                    maxWidth: (_bp != 'mediumHandset') ? globals.maxIzq : MediaQuery.of(context).size.width,
                    minHeight: globals.minH
                  ),
                  child: LoginFrmIzq(constraints: constraints),
                ),
                if(_bp != 'mediumHandset')
                  Expanded(
                    child: SizedBox(
                      height: _maxH,
                      child: LoginUiDer()
                    ),
                  )
              ],
            );
          }
        ),
      ),
    );
  }

}