import 'package:autoparnet_cotiza/src/entity/orden.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'repos_ctrs_holder.dart';
import 'repos_ctrls.dart';
import '../data_shared/ds_repo.dart';
import '../../../providers/repos_proceso_prov.dart';

class MisProcesos extends StatefulWidget {

  final ValueChanged<String> onChangeSeccion;
  final ValueChanged<int> onTap;
  const MisProcesos({
    Key? key,
    required this.onChangeSeccion,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MisProcesos> createState() => _MisProcesosState();
}

class _MisProcesosState extends State<MisProcesos> {

  late Future<bool> _buscandoProcesos;
  final Globals globals = getSngOf<Globals>();
  final DsRepo _dsRepo = getSngOf<DsRepo>();
  
  String titulo = 'CALCULANDO...';
  String subtitulo = 'UN MOMENTO POR FAVOR';
  String desc = 'Buscando procesos';

  @override
  void initState() {
    _buscandoProcesos = _buscarProcesos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
      future: _buscandoProcesos,
      builder: (_, AsyncSnapshot snap) {

        if(snap.connectionState == ConnectionState.done) {

          if(!snap.data) {
            titulo = 'SIN PROCESAR';
            subtitulo = 'Visualiza tus Solicitudes';
            desc = 'Lista de contizaciones';
          }else{
            titulo = 'DATA';
          }
        }

        return Consumer<ReposProcesoProv>(
          builder: (_, repo, ___) {

            if(repo.inSceneRepo.isNotEmpty) {
              return ReposCtrls(
                tipo: 'EN PROCESAMIENTO',
                hasNotif: repo.hasNotif,
                onTap: (_) {
                  hiddeBellNotif();
                  _dsRepo.idRepoMainSelectCurrent = repo.inSceneRepo['idMain'];
                  widget.onTap(repo.puntero);
                },
                onNext: (_) {
                  hiddeBellNotif();
                  repo.showNextRepo();
                },
                onBack: (_) {
                  hiddeBellNotif();
                  repo.showPreviewRepo();
                },
                onSee: (_) {
                  hiddeBellNotif();
                  widget.onChangeSeccion('lst_enproceso');
                },
                onRefresh: (_) async => await _buscarProcesos(),
              );
            }else{

              return ReposCtrlHolder(
                titulo: titulo,
                subtitulo: subtitulo,
                desc: desc,
                seccion: 'proceso',
                isOf: true,
                onRefresh: (val) async => await _buscarProcesos()
              );
            }
          }
        );
      },
    );
  }

  //
  void hiddeBellNotif() {
    if(context.read<ReposProcesoProv>().hasNotif) {
      setState(() {
        context.read<ReposProcesoProv>().hasNotif = false;
      });
    }
  }

  ///
  Future<bool> _buscarProcesos() async {

    _dsRepo.initConfig();
    List<int> todasEnProcesos = [];
    Iterable<Orden>? ordenes = _dsRepo.orden.values.where((element) => element.est == '2');

    if(ordenes.isNotEmpty) {
      ordenes.map((e) => todasEnProcesos.add(e.key)).toList();
    }
    ordenes = null;
    if(todasEnProcesos.isNotEmpty) {
      final repo = context.read<ReposProcesoProv>();
      repo.addallKeys = todasEnProcesos;
      repo.setInSceneByKeyRepo(-1);
      return true;
    }

    return false;
  }

}