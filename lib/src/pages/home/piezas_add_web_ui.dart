import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';

import 'data_shared/ds_repo.dart';
import 'widgets_home/frm_cotiza.dart';
import 'widgets_home/titulo_page.dart';
import 'widgets_home/lienzo_content.dart';
import 'widgets_home/btn_segun_seccion.dart';
import 'widgets_home/lst_pizas_to_cotizar.dart';
import '../../widgets/get_fotos/singleton/picker_pictures.dart';
import '../../providers/pestanias_prov.dart';
import '../../widgets/varios_widgets.dart';

class PiezasAddWebUI extends StatelessWidget {

  final BoxConstraints constraints;
  PiezasAddWebUI({
    required this.constraints,
    Key? key
  }) : super(key: key);

  final globals = getSngOf<Globals>();
  final refCotiz= getSngOf<RefCotiz>();
  final dsRepo  = getSngOf<DsRepo>();
  final pictures= getSngOf<PickerPictures>();

  final VariosWidgets variosWidgets = VariosWidgets();
  final ValueNotifier<int> keyPiezaEdit = ValueNotifier(-1);
  final ValueNotifier<bool> showPiezasWeb = ValueNotifier(false);
  final ScrollController scrol = ScrollController();

  @override
  Widget build(BuildContext context) {

    double alto = MediaQuery.of(context).size.height * 0.85;

    Widget contenido = (constraints.maxWidth <= globals.tabletMin)
    ? Container(
        width: constraints.maxWidth,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5)
          )
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: showPiezasWeb,
          builder: (_, showPzas, __) {

            return ListView(
              controller: scrol,
              shrinkWrap: true,
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: (!showPzas) ? alto : alto * 0.7,
                  child: _ladoFrm(context, constraints),
                ),
                if(showPzas)
                  SizedBox(
                    width: constraints.maxWidth,
                    height: alto,
                    child: _ladoPzs(context, constraints, renderFrom: 'row'),
                  )
              ],
            );
          },
        ),
      )
    : Row(children: [
        Expanded(child: _ladoFrm(context, constraints)),
        Expanded(child: _ladoPzs(context, constraints, renderFrom: 'row')),
      ]);

    return LienzoContent(
      constraints: constraints,
      child: contenido
    );
  }

  ///
  Widget _ladoFrm(BuildContext context, BoxConstraints constraints) {

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[400]!, width: 0.5),
        )
      ),
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: keyPiezaEdit,
          builder: (_, int keyPza, __) {
            
            return FrmCotiza(
              constraints: constraints,
              onChangeScreen: (hasFotos){
                showPiezasWeb.value = hasFotos;
              },
              onFinish:(value) {
                if(dsRepo.idRepoMainSelectCurrent > 0) {
                  context.read<PestaniasProv>().pestaniaSelect = 'Cotizar';
                }
              },
            );
          },
        )
      ),
    );
  }

  ///
  Widget _ladoPzs(BuildContext context, BoxConstraints constraints, {required String renderFrom}) {
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TituloPage(
                  icono: Icons.list_alt_outlined,
                  tipo: 'pzaas',
                  tamRadius: 10,
                ),
              ),
              const SizedBox(width: 10),
              BtnSegunSeccion()
            ]
          ),
          const Divider(),
          (renderFrom == 'row')
          ? Expanded(child: _listaDePiezas(context))
          : _listaDePiezas(context)
        ],
      ),
    );
  }

  ///
  Widget _listaDePiezas(BuildContext context) {

    return LstPiezasToCotizar(
      onTapForEdit: (int keyEdit) async {
        keyPiezaEdit.value = keyEdit;
      },
      onDelete: (keyDel) async {
        pictures.cleanImgs();
        await dsRepo.putNewPiezasInProvider(context);
      },
      onSaved: (Map<String, int> keyId) async {},
    );
  }

}