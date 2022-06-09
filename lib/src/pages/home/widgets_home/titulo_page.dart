import 'package:autoparnet_cotiza/src/providers/pzas_to_cotizar_prov.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:provider/provider.dart';

import '../data_shared/ds_repo.dart';

class TituloPage extends StatelessWidget {

  final IconData icono;
  final double tamRadius;
  final String tipo;
  TituloPage({
    required this.icono,
    required this.tamRadius,
    this.tipo = 'orden',
    Key? key
  }) : super(key: key);

  final globals = getSngOf<Globals>();
  final dsRepo  = getSngOf<DsRepo>();
  
  @override
  Widget build(BuildContext context) {

    final bp = globals.getDeviceFromMediaQuery(context);
    final radio = (bp != 'mediumHandset' && kIsWeb) ? 25.0 : 30.0;
    
    return Container(
      height: (bp == 'mediumHandset') ? 70 : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tamRadius),
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Colors.grey[800]!
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          if((bp != 'mediumHandset'))
            Icon(icono, color: Colors.blue),
          Text(
            (tipo == 'orden') ? 'COTIZANDO PIEZAS' : 'PIEZAS',
            textScaleFactor: 1,
            style: globals.styleText(
              (bp != 'mediumHandset') ? 14 : 18,
              Colors.blue,
              true
            )
          ),
          const Spacer(),
          if(tipo == 'orden')
            Text(
              'ORDEN: ',
              textScaleFactor: 1,
              style: globals.styleText(
                (bp != 'mediumHandset') ? 14 : 18,
                Colors.white,
                true
              )
            ),
          Container(
            height: radio, width: radio+10,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radio),
              color: Colors.red
            ),
            child: Center(
              child: Text(
                (tipo == 'orden')
                ? '${dsRepo.idRepoMainSelectCurrent}'
                : '${context.watch<PzasToCotizarProv>().keysPiezas.length}',
                overflow: TextOverflow.ellipsis,
                textScaleFactor: 1,
                style: globals.styleText(
                  (kIsWeb) ? 12 : 16,
                  Colors.white,
                  true
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}