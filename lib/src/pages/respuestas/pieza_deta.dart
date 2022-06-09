import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'view_galery.dart';

class PiezaDeta extends StatelessWidget {

  final Map<String, dynamic> pza;
  final int idRepoMain;
  final double maxWidth;
  final ScrollController scrollCtr;

  PiezaDeta({
    Key? key,
    required this.pza,
    required this.idRepoMain,
    required this.maxWidth,
    required this.scrollCtr,
  }) : super(key: key);

  final Globals globals = getSngOf<Globals>();
  
  @override
  Widget build(BuildContext context) {
    
    return _body(context);
  }

  ///
  Widget _body(BuildContext context) {

    return ListView(
      controller: scrollCtr,
      children: [
        if(pza['fotos'].isNotEmpty)
          SizedBox(
            width: maxWidth,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Stack(
              children: [
                (pza['fotos'].isNotEmpty)
                ? ViewGalery(
                  maxWidth: maxWidth,
                  fotos: pza['fotos'],
                  idRepoMain: idRepoMain,
                )
                : Center(
                    child: Image.asset('assets/images/no-logo.png'),
                  ),
                if(!kIsWeb)
                  // en la APP mostramos el btn para cerrar
                  Positioned(
                    top: 40, left: 10,
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
          )
        else
          SizedBox(
            width: maxWidth,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Image.asset('assets/images/no-logo.png'),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            pza['obs'],
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: globals.styleText(16, Colors.grey[600]!, false),
          ),
        )
      ],
    );
  }
}