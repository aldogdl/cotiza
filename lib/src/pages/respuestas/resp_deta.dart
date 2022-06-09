import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/scroll_config.dart';

import 'view_galery.dart';

class RespDeta extends StatelessWidget {

  final Map<String, dynamic> resp;
  final int idRepoMain;
  final double maxWidth;
  final ScrollController scrollCtr;
  RespDeta({
    Key? key,
    required this.resp,
    required this.maxWidth,
    required this.idRepoMain,
    required this.scrollCtr
  }) : super(key: key);

  final Globals globals = getSngOf<Globals>();
  final f = NumberFormat.currency(customPattern: "\$ #,##0.0#", decimalDigits: 2, locale: 'en_US');
  

  @override
  Widget build(BuildContext context) {

    if(!kIsWeb) {
      return _body(context);
    }

    return Scrollbar(
      thumbVisibility: true,
      controller: scrollCtr,
      radius: const Radius.circular(0),
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: _body(context),
      ),
    );
  }

  ///
  Widget _body(BuildContext context) {

    double paddingR = (kIsWeb) ? 15 : 0;

    return ListView(
      controller: scrollCtr,
      shrinkWrap: true,
      padding: EdgeInsets.only(right: paddingR),
      semanticChildCount: 2,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Stack(
            children: [
              (resp['info_fotos'].isNotEmpty)
              ? ViewGalery(
                  maxWidth: maxWidth,
                  fotos: List<String>.from(resp['info_fotos']),
                  idRepoMain: idRepoMain,
                  idInfo: resp['info_id'],
                )
              : Center(
                  child: Image.asset('assets/images/no-logo.png'),
                ),
              if(!kIsWeb)
                // en la APP mostramos el btn para cerrar
                Positioned(
                  top: 10, left: 10,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  )
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                resp['info_caracteristicas'],
                textScaleFactor: 1,
                style: globals.styleText(21, Colors.grey, false),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: double.maxFinite,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.green,
                    Color(0xff232323)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight
                )
              ),
              child: Row(
                children: [
                  Text(
                    'Detalles de su estado:',
                    textScaleFactor: 1,
                    style: globals.styleText(16, Colors.black, true),
                  ),
                  const Spacer(),
                  Text(
                    f.format(resp['info_precio']),
                    textScaleFactor: 1,
                    style: globals.styleText(16, Colors.white, true),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                (resp['info_detalles'] == '0') ? 'Sin detalles' : resp['info_detalles'],
                textScaleFactor: 1,
                style: globals.styleText(18, Colors.white, false),
              ),
            )
          ],
        )
      ],
    );
  }


}