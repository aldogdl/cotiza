import 'package:flutter/material.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

class ContainerBuildFoto extends StatelessWidget {

  final BoxConstraints constraints;
  final String callFrom;
  final Widget child;

  ContainerBuildFoto({
    required this.constraints,
    required this.child,
    this.callFrom = 'web',
    Key? key
  }) : super(key: key);

  final double tamRadius = 10;
  final globals = getSngOf<Globals>();

  @override
  Widget build(BuildContext context) {

    double pad = (globals.isMobileDevice) ? 8 : 0;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: (callFrom == 'mobil') ? 130 : null,
      padding: EdgeInsets.symmetric(vertical: pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tamRadius),
        border: Border.all(
          color: Colors.blue,
          width: 1
        ),
      ),
      child: child
    );
  }
}