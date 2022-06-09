import 'package:autoparnet_cotiza/src/repository/stt_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';

import 'label_icon_btn.dart';
import '../data_shared/ds_repo.dart';
import '../../../providers/pestanias_prov.dart';
import '../../../providers/repos_proceso_prov.dart';
import '../../../providers/pzas_to_cotizar_prov.dart';
import '../../../providers/btn_send_cotizacion_prov.dart';
import '../../../providers/repos_pendientes_prov.dart';
import '../../../repository/repos_repository.dart';

class BtnSegunSeccion extends StatelessWidget {

  final ValueChanged<void>? onTap;
  final ValueChanged<void>? onFinish;
  BtnSegunSeccion({
    Key? key,
    this.onTap,
    this.onFinish,
  }) : super(key: key);

  final Globals globals = getSngOf<Globals>();
  final RefCotiz refCotiz = getSngOf<RefCotiz>();
  final DsRepo dsRepo = getSngOf<DsRepo>();

  final RepoRepository _repoEm = RepoRepository();
  final SttRepository _sttEm = SttRepository();

  @override
  Widget build(BuildContext context) => _btnSegunPageCurrent(context);

  ///
  Widget _btnSegunPageCurrent(BuildContext context) {

    final bp = globals.getDeviceFromMediaQuery(context);
    late Function? acc;
    String label = '0';
    
    switch (context.read<PestaniasProv>().pestaniaSelect) {
      case 'Cotizar':
        label = 'ENVIAR';
        acc = () async => await _sendCotizacion(context);
        break;
      case 'Cotizaciones':
        label = 'Hacer Pedido';
        acc = () async => await _sendPedido(context);
        break;
      default:
    }

    if(label == '0') {
      return const SizedBox();
    }

    return SizedBox(
      height: (bp == 'mediumHandset') ? 70 : 38,
      child: Selector<BtnSendCotizacionProv, bool>(
        selector: (_, provi) => provi.activeBtnSend,
        builder: (_, provBtn, __) {
          
          return AbsorbPointer(
            absorbing: !provBtn,
            child: ElevatedButton(
              style: ButtonStyle(
              elevation: MaterialStateProperty.all(4),
                backgroundColor: MaterialStateProperty.all(
                  (provBtn)
                  ? const Color.fromARGB(255, 178, 190, 5)
                  : const Color.fromARGB(255, 35, 35, 35)
                ),
                foregroundColor: MaterialStateProperty.all(
                  (provBtn) ? Colors.black : Colors.grey[800]!
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: (acc != null) ? () => acc!() : null,
              child: LabelIconBtn(
                label: label,
                icono: Icons.send,
                fg: (provBtn) ? Colors.black : Colors.grey[800]!,
                colorIcon: (provBtn) ? Colors.white : Colors.grey[800]!
              )
            ),
          );
        },
      )
    );
  }

  ///
  Future<void> _sendCotizacion(BuildContext context) async {

    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();

    final proviBtn = context.read<BtnSendCotizacionProv>();
    proviBtn.activeBtnSend = false;
    await proviBtn.setActiveLoaderSend(true);
    if(onTap != null) {
      onTap!(null);
    }

    Future.delayed(const Duration(microseconds: 100), () async {

      final pzaCurrent = context.read<PzasToCotizarProv>();
      final pendientesProv = context.read<ReposPendientesProv>();
      final procesoProv = context.read<ReposProcesoProv>();
      final pestania = context.read<PestaniasProv>();
      await _repoEm.enviarOrden(dsRepo.idRepoMainSelectCurrent);
      
      if(!_repoEm.result['abort']) {

        if(_repoEm.result['msg'] == 'si-save') {
          await _sttEm.changeSttToOrden( Map<String, dynamic>.from(_repoEm.result['body']['ord']) );
          await _sttEm.changeSttToPiezas( Map<String, dynamic>.from(_repoEm.result['body']['pza']) );
        }
        pzaCurrent.disposeTotal();

        int idOrden = await pendientesProv.eliminarCurrentPendiente(deleteFull: false);
        await pendientesProv.showNextRepo();
        if(pendientesProv.inSceneRepo.isNotEmpty) {

          dsRepo.idRepoMainSelectCurrent = pendientesProv.inSceneRepo['idMain'];
          pzaCurrent.buildPzaNewOfOrden(idOrd: dsRepo.idRepoMainSelectCurrent);
          Future.delayed(const Duration(milliseconds: 100), (){
            context.read<PestaniasProv>().pestaniaSelect = 'Cotizar';
          });
          
        }else{
          dsRepo.idRepoMainSelectCurrent = 0;
          pestania.pestaniaSelect = 'none';
        }
        pzaCurrent.clearPzaToSend();

        procesoProv.addToKeys = await dsRepo.getKeyRepoMainById(idOrden);
        await procesoProv.setInSceneByKeyRepo(-1);

        await proviBtn.setActiveLoaderSend(false);
        if(!kIsWeb) {
          // call from frmCotiza.dart
          if(onFinish != null) {
            onFinish!(null);
          }
        }

      }else{
        proviBtn.activeBtnSend = true;
        await proviBtn.setActiveLoaderSend(false);
      }
    });
  }

  ///
  Future<void> _sendPedido(BuildContext context) async {

    final procesoProv = context.read<ReposProcesoProv>();
    final pestania = context.read<PestaniasProv>();

    dsRepo.getRespuestaPedidoForSend().then((Map<String, dynamic> dataSend) async {

      bool? res = await refCotiz.showDialogAndSendPedido(context, dataSend);
      if(res != null) {
        if(res) {
          // Revisar si hay un repo en proceso en scene
          if(procesoProv.inSceneRepo.isNotEmpty) {
            dsRepo.idRepoMainSelectCurrent = procesoProv.inSceneRepo['idMain'];
            pestania.pestaniaSelect = 'Cotizaciones';
          }
        }
      }
    });
  }

}