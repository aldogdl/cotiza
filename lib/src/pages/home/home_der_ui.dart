import 'package:intl/intl.dart' show NumberFormat;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'data_shared/ds_repo.dart';
import 'change_page_ui.dart';
import 'piezas_add_web_ui.dart';
import 'cotizaciones_ui.dart';
import '../../providers/pestanias_prov.dart';
import '../../widgets/varios_widgets.dart';

class HomeDerUI extends StatelessWidget {

  HomeDerUI({Key? key}) : super(key: key);

  final Globals globals = getSngOf<Globals>();
  final RefCotiz refCotiz = getSngOf<RefCotiz>();
  final DsRepo dsRepo = getSngOf<DsRepo>();
  
  final VariosWidgets variosWidgets = VariosWidgets();

  final ScrollController scrol = ScrollController();
  final NumberFormat f = NumberFormat.currency(customPattern: "\$ #,##0.0#", decimalDigits: 2, locale: 'en_US');
  
  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        return Column(
          children: [
            Expanded(
              child: _contenido(constraints, context)
            )
          ],
        );
      },
    );
  }

  ///
  Widget _contenido(BoxConstraints constraints, BuildContext context) {
    
    switch (context.watch<PestaniasProv>().pestaniaSelect) {

      case 'Cotizar':
         return PiezasAddWebUI(constraints: constraints);
      case 'Cotizaciones':
         return CotizacionesUI(constraints: constraints);
      default:
      return ChangePageUi(constraints: constraints);
    
    }
  }

}