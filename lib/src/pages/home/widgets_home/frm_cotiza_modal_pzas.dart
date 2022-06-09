import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../repository/repos_repository.dart';
import '../../../widgets/get_fotos/singleton/picker_pictures.dart';
import '../../../widgets/varios_widgets.dart';
import 'tile_pza_before_cot.dart';
import '../../../../config/sng_manager.dart';
import '../../../../vars/globals.dart';
import '../../../providers/btn_send_cotizacion_prov.dart';
import '../../../providers/pzas_to_cotizar_prov.dart';
import '../data_shared/ds_repo.dart';
import 'btn_segun_seccion.dart';

class FrmCotizaModalPzas extends StatefulWidget {

  final ValueChanged<int> onEdit;
  const FrmCotizaModalPzas({
    Key? key,
    required this.onEdit
  }) : super(key: key);

  @override
  State<FrmCotizaModalPzas> createState() => _FrmCotizaModalPzasState();
}

class _FrmCotizaModalPzasState extends State<FrmCotizaModalPzas> {

  final _repoEm = RepoRepository();
  final globals = getSngOf<Globals>();
  final dsRepo  = getSngOf<DsRepo>();
  final picktures = getSngOf<PickerPictures>();
  final variosWidgets = VariosWidgets();

  late final PzasToCotizarProv pzaCurrent;
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {
    
    if(!_isInit) {
      _isInit = true;
      pzaCurrent = context.read<PzasToCotizarProv>();
    }
    
    double altura = double.parse('${pzaCurrent.keysPiezas.length}');
    double h = MediaQuery.of(context).size.height;
    
    if(altura > 0) {
      for (var i = 0; i < pzaCurrent.keysPiezas.length; i++) {
        if(i == 0) {
          altura = h * 0.06;
        }
        altura = altura + (h * 0.08);
      }
    }else{
      altura = h * 0.06;
    }

    altura = (altura > (h * 0.8)) ? (h * 0.8) : altura;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.black
          ),
          child: Row(
            children: [
              Text(
                'FIN DE LA SOLICITUD',
                textScaleFactor: 1,
                style: globals.styleText(18, Colors.grey, true)
              ),
              const Spacer(),
              BtnSegunSeccion(
                onTap: (_) async => await _sendPzaToServer(),
                onFinish: (_) {
                  if(mounted) {
                    if(Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(true);
                    }
                  }
                }
              )
            ]
          )
        ),
        Container(
          height: altura,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3
          ),
          child: Column(
            children: [
              if(context.watch<BtnSendCotizacionProv>().activLoaderSend)
                const LinearProgressIndicator(),
              Expanded(
                child: ListView.builder(
                  itemCount: pzaCurrent.keysPiezas.length,
                  itemBuilder: (_, int indexKey) {

                    var pza = dsRepo.ordenPzas.get(pzaCurrent.keysPiezas.elementAt(indexKey));
                    if(pza == null) { return const SizedBox(height: 0, width: 0); }

                    return TilePzaBeforeCot(
                      pieza: pza,
                      onAction: (Map<String, dynamic> action) async {

                        if(action['onpress'] == 'edit') {
                          
                          picktures.fotosFromServer = pza.fotos;
                          widget.onEdit(action['keyPieza']);
                          Navigator.of(context).pop(false);
                        }else{
                          await _eliminarPiezaFromModal(action['keyPieza']);
                        }
                      }
                    );
                  }
                ),
              )
            ],
          )
        )
      ]
    );
  }

  ///
  Future<void> _eliminarPiezaFromModal(int keyPieza) async {

    final prov = context.read<BtnSendCotizacionProv>();
    final nav = Navigator.of(context);
    bool? acc = await variosWidgets.dialog(
      cntx: context,
      tipo: 'yesOrNot',
      icono: Icons.delete_forever,
      colorIcon: Colors.red,
      titulo: 'ELIMINANDO AUTOPARTE',
      textMain: 'Se eliminará permanentemente la refacción indicada.',
      textSec: '¿Estás segur@ de continuar?'
    );

    if(acc ?? false) {

      var pza = dsRepo.ordenPzas.get(keyPieza);
      if(pza != null) {

        await prov.setActiveLoaderSend(true);
        bool res = await _repoEm.deletePiezaAntesDeSave(pza.id);

        if(res) {
          await pza.delete();
          await dsRepo.ordenPzas.compact();
          picktures.cleanImgs();
          if(!mounted) return;
          await dsRepo.putNewPiezasInProvider(context);
        }
        prov.setActiveLoaderSend(false);
      }
      
      if(!prov.activeBtnSend) { nav.pop(false); }
      
      final hasMore = dsRepo.ordenPzas.values.where((e) => e.orden == dsRepo.idRepoMainSelectCurrent);
      if(hasMore.isEmpty) { nav.pop(false); }

      setState(() {});
    }
  }

  ///
  Future<void> _sendPzaToServer() async {

    await for (var keyPza in _repoEm.sendPzaStream(pzaCurrent.pzasToSend)) {

      if(keyPza['key'] != -1) {
        await pzaCurrent.changeDataWith(keyPza['key']!, true);
        setState(() {});
        Future.delayed(const Duration(milliseconds: 350), (){
          Navigator.of(context).pop(true);
        });
      }
    }
  }

}