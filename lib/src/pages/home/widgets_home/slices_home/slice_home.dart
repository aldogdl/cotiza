import 'package:autoparnet_cotiza/src/pages/home/widgets_home/slices_home/cotiza_aqui.dart';
import 'package:autoparnet_cotiza/src/pages/home/widgets_home/slices_home/refa_digital.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:flutter/material.dart';

class SlicesHome extends StatelessWidget {

  final BoxConstraints constraints;
  final Globals globals;
  const SlicesHome({
    Key? key,
    required this.constraints,
    required this.globals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double maxW = globals.getMaxWidht(constraints);
    double maxH = globals.getHeight(context);

    return Container(
      constraints: BoxConstraints.expand(
        width: maxW,
        height: (maxH <= 650) ? 200 : maxH * 0.28,
      ),
      decoration: const BoxDecoration(
        color: Colors.black87
      ),
      child: SizedBox.expand(
        child: PageView(
          controller: PageController(),
          physics: const BouncingScrollPhysics(),
          children: [
            RefaDigital(maxW: maxW),
            CotizaAqui(maxW: maxW)
          ],
        ),
      ),
    );
  }
}