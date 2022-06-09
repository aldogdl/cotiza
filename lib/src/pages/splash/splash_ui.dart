import 'package:flutter/material.dart';

import 'splash_controller.dart';

class SplashUI extends StatelessWidget {

  final BuildContext contextParent;
  final SplashControllerState ctr;
  const SplashUI(this.contextParent, this.ctr, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _gif(),
              const SizedBox(height: 20),
              Text(
                ctr.taskMsg,
                textScaleFactor: 1,
                textAlign: TextAlign.center,
                style: ctr.globals.styleText(
                  15,
                  const Color(0xff5FB131),
                  true
                )
              ),
            ],
          ),
        )
      ),
    );
  }

  ///
  Widget _gif() {

    return const Opacity(
      opacity: 0.5,
      child: Image(
        image: AssetImage('assets/images/pistones.gif'),
      ),
    );
  }

}