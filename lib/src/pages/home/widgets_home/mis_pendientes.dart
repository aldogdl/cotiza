import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import '../../../../vars/ref_cotiz.dart';
import 'repos_ctrls.dart';
import 'repos_ctrs_holder.dart';
import '../data_shared/ds_repo.dart';
import '../../../providers/pestanias_prov.dart';
import '../../../providers/repos_pendientes_prov.dart';
import '../../../providers/pzas_to_cotizar_prov.dart';
import '../../../repository/repos_repository.dart';
import '../../../widgets/varios_widgets.dart';
import '../../../widgets/get_fotos/singleton/picker_pictures.dart';

class MisPendientes extends StatefulWidget {
  
  final ValueChanged<String> onChangeSeccion;
  final ValueChanged<Map<String, dynamic>> onTap;
  const MisPendientes({
    Key? key,
    required this.onChangeSeccion,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MisPendientes> createState() => _MisPendientesState();
}

class _MisPendientesState extends State<MisPendientes> {

  final DsRepo _dsRepo = getSngOf<DsRepo>();
  final PickerPictures _picktures = getSngOf<PickerPictures>();
  final Globals globals = getSngOf<Globals>();
  final VariosWidgets variosWidgets = VariosWidgets();
  final RepoRepository _repoEm = RepoRepository();

  late Future<bool> _buscandoProcesos;
  String titulo = 'CALCULANDO...';
  String subtitulo = 'UN MOMENTO POR FAVOR';
  String desc = 'Buscando procesos';
  bool _isInitBoxes = false;

  @override
  void initState() {
    _buscandoProcesos = _buscarProcesos(context.read<ReposPendientesProv>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
      future: _buscandoProcesos,
      builder: (_, AsyncSnapshot snap) {

        if(snap.connectionState == ConnectionState.done) {

          return Consumer<ReposPendientesProv>(
            builder: (_, pendienteProv, ___) {

              if(pendienteProv.inSceneRepo.isEmpty) {
                _setSinPendientesTitulares();
                return holder(pendienteProv);
              }

              return ReposCtrls(
                tipo: 'PENDIENTES',
                onTap: (_) async => await _isSameRepoAndAction('onTap', pendienteProv),
                onNext:(_) async => await _isSameRepoAndAction('onNext', pendienteProv),
                onBack:(_) async => await _isSameRepoAndAction('onBack', pendienteProv),
                onSee: (_)  => widget.onChangeSeccion('lst_pendientes'),
                onRefresh:(_) async => await _buscarProcesos(pendienteProv),
                onDelete: (_) async => _eliminarOrden(pendienteProv)
              );
            }
          );
        }
        return holder(context.read<ReposPendientesProv>());
      },
    );
  }

  ///
  Future<void> _isSameRepoAndAction(String accion, ReposPendientesProv provi) async {

    final prov = context.read<PzasToCotizarProv>();
    final pestania = context.read<PestaniasProv>();

    switch (accion) {
      case 'onTap':
        await _dsRepo.isSameRepoSelect(context);
        widget.onTap({'acc':'frm', 'idMain': provi.inSceneRepo['idMain']});
        break;
      case 'onNext':
        bool canChange = await canChangeOfOrden(provi, 'onNext');
        if(canChange) {
          
          pestania.pestaniaSelect = 'Cotizar';
          await provi.showNextRepo();
          if(mounted) {
            await _dsRepo.isSameRepoSelect(context, idOrdenS: provi.inSceneRepo['idMain']);
          }
          
          prov.hasFotos = false;
          prov.buildPzaNewOfOrden(idOrd: _dsRepo.idRepoMainSelectCurrent);
          _picktures.cleanImgs();
          widget.onTap({'acc':'next', 'idMain': provi.inSceneRepo['idMain']});
        }
        break;
      case 'onBack':
        bool canChange = await canChangeOfOrden(provi, 'onBack');
        if(canChange) {

          pestania.pestaniaSelect = 'Cotizar';
          await provi.showPreviewRepo();
          if(mounted) {
            await _dsRepo.isSameRepoSelect(context, idOrdenS: provi.inSceneRepo['idMain']);
          }

          prov.hasFotos = false;
          prov.buildPzaNewOfOrden(idOrd: _dsRepo.idRepoMainSelectCurrent);
          _picktures.cleanImgs();
          widget.onTap({'acc':'back', 'idMain': provi.inSceneRepo['idMain']});
        }
        break;
      default:
    }
  }

  ///
  Future<bool> canChangeOfOrden(ReposPendientesProv provi, String from) async {

    final otraOrden =  (from == 'onNext')
    ? await provi.getNextRepo()
    : await provi.getPreviewRepo();

    if(otraOrden != _dsRepo.idRepoMainSelectCurrent) {
      // Esta queriendo cambiar de orden en el contenedor
      if(_picktures.imageFileListOks.isNotEmpty) {
        bool? acc = await variosWidgets.dialog(
          cntx: context,
          tipo: 'yesOrNot',
          icono: Icons.delete_forever,
          colorIcon: Colors.red,
          titulo: 'REGISTRO DE PIEZA EN PROGRESO',
          textMain: 'Estás en medio de un registro de pieza pendiente.\n '
          'Preciona SÍ, si deseas que el registro de la pieza actual\n '
          'sea eliminado antes de cambiar de Orden.',
          textSec: 'Presiona NO, para continuar con el registro de la pieza actual.'
        );
        return acc ?? false;
      }else{
        return true;
      }
    }else{
      return true;
    }
  }

  ///
  Future<bool> _buscarProcesos(ReposPendientesProv provi) async {

    bool resp = false;

    if(!_isInitBoxes) {
      await _dsRepo.initConfig();
      _isInitBoxes = true;
    }
    
    List<int> todasLasPendientes = [];
    _dsRepo.orden.values.map((e) {
      if(e.est == '1') {
        todasLasPendientes.add(e.key);
      }
    }).toList();

    if(todasLasPendientes.isNotEmpty) {

      provi.addallKeys = todasLasPendientes;
      if(_dsRepo.idRepoMainSelectCurrent == 0) {
        await provi.setInSceneByKey(-1);
        if(provi.inSceneRepo.isNotEmpty) {
          _dsRepo.idRepoMainSelectCurrent = provi.inSceneRepo['idMain'];
        }
      }else{
        int key = await _dsRepo.getKeyRepoMainById(_dsRepo.idRepoMainSelectCurrent);
        await provi.setInSceneByKey(key);
      }
      if(mounted) {
        await _dsRepo.putNewPiezasInProvider(context);
        resp = true;
      }
    }
    todasLasPendientes = [];
    return resp;
  }

  ///
  Future<void> _eliminarOrden(ReposPendientesProv provi) async {

    final pestania = context.read<PestaniasProv>();
    final pzaCurrent = context.read<PzasToCotizarProv>();
    bool? acc = await variosWidgets.dialog(
      cntx: context,
      tipo: 'yesOrNot',
      icono: Icons.delete_forever,
      colorIcon: Colors.red,
      titulo: 'ELIMINAR SOLICITUD PENDIENTE',
      textMain: 'Se eliminará permanentemente la solicitud seleccionada.',
      textSec: '¿Estas segur@ de continuar?'
    );

    if(acc ?? false) {

      final refCotz = getSngOf<RefCotiz>();
      pestania.pestaniaSelect = 'none';
      int idOrden = await provi.eliminarCurrentPendiente();
      
      if(_dsRepo.ordenPzas.values.isNotEmpty) {

        final pza = _dsRepo.ordenPzas.values.where((element) => element.orden == idOrden).toList();
        if(pza.isNotEmpty) {
          for (var i = 0; i < pza.length; i++) {
            await _repoEm.deletePiezaAntesDeSave(pza[i].id);
            pza[i].delete();
          }
        }
        _dsRepo.ordenPzas.compact();
      }
      await _repoEm.deleteOrdenFromServer(idOrden);
      pzaCurrent.keysPiezas.clear();
      refCotz.keyPiezaEdit = -1;
    }
  }
  
  ///
  void _setSinPendientesTitulares() {
    titulo = 'SIN PENDIENTES';
    subtitulo = 'Cotiza Refacciónes HOY';
    desc = 'Estamos a tus ordenes';
  }

  ///
  Widget holder(ReposPendientesProv provi) {

    return ReposCtrlHolder(
      titulo: titulo,
      subtitulo: subtitulo,
      desc: desc,
      seccion: 'pendientes',
      isOf: true,
      onRefresh: (val) async => await _buscarProcesos(provi)
    );
  }

}