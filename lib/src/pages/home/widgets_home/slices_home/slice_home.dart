import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/vars/globals.dart';

import 'slice_main.dart';

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
    List<Map<String, dynamic>> x = _contents();
    final ctr = PageController();
  
    return Container(
      constraints: BoxConstraints.expand(
        width: maxW,
        height: (maxH <= 650) ? 200 : maxH * 0.28,
      ),
      decoration: const BoxDecoration(
        color: Colors.black87
      ),
      child: SizedBox.expand(
        child: PageView.builder(
          controller: ctr,
          physics: const BouncingScrollPhysics(),
          itemCount: x.length,
          itemBuilder: (_, index) {

            return SliceMain(
              pageCtr: ctr,
              maxW: maxW,
              data: x[index],
              itemCount: x.length,
              index: index,
            );
          },
        ),
      ),
    );
  }

  ///
  List<Map<String, dynamic>> _contents() {

    return [
      {
        'titulo': 'La Refaccionaria Digital más Grande de México',
        'parrafo': 'Contamos con una red de cientos de proveedores lo cual te '
          'GARANTIZA, encontrar las autopartes que necesitas.',
        'poster': {
          'label1': 'RASTREAMOS', 'label2': 'TUS AUTOPARTES', 'ico': Icons.extension
        },
      },
      {
        'titulo': 'Nunca fue tan fácil COTIZAR refacciones',
        'parrafo': 'Tú presiona un botón. Nosotros, nos encargamos del resto. '
          'Compara PRECIO, CALIDAD y SERVICIO.',
        'poster': {
          'label1': 'TE ENVIAMOS', 'label2': 'COTIZACIONES', 'ico': Icons.list_alt
        },
      },
      {
        'titulo': '¿Atrasado en tu trabajo por falta de piezas?',
        'parrafo': '¡No te preocupes! nosotros te ayudamos en la BÚSQUEDA, COSTO y '
          'entrega a DOMICILIO.',
        'poster': {
          'label1': 'A LA PUERTA', 'label2': 'DE TU TALLER', 'ico': Icons.delivery_dining
        },          
      },
    ];
  }
}