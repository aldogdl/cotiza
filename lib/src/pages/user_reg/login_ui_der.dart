import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

class LoginUiDer extends StatelessWidget {

  LoginUiDer({Key? key}) : super(key: key);

  final globals = getSngOf<Globals>();
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: 500,
      height: 500,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: SvgPicture.asset(
              'assets/svgs/login.svg',
              semanticsLabel: 'Login',
              alignment: Alignment.topCenter,
              fit: BoxFit.contain,
              height: 300,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Bienvenido!',
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: globals.styleText(35, Colors.black, true)
          ),
          const SizedBox(height: 10),
          Text(
            'AutoparNet, Tu Refaccionaria digital más Grande de México',
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: globals.styleText(20, Colors.black, false)
          )
        ]
      )
    );
  }
}