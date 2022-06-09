import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/scroll_config.dart';

import 'repo_titulo.dart';
import 'repos_card.dart';
import '../data_shared/ds_repo.dart';
import '../../../providers/pestanias_prov.dart';

class SeccLstEnProceso extends StatefulWidget {

  final BoxConstraints constraints;
  final List<int> lstKeys;
  final ValueChanged<int> onTap;
  const SeccLstEnProceso({
    Key? key,
    required this.constraints,
    required this.lstKeys,
    required this.onTap
  }) : super(key: key);

  @override
  State<SeccLstEnProceso> createState() => _SeccLstEnProcesoState();
}

class _SeccLstEnProcesoState extends State<SeccLstEnProceso> {

  final Globals globals = getSngOf<Globals>();
  final DsRepo _dsRepo = getSngOf<DsRepo>();
  final ScrollController _scrollEnProceso = ScrollController();

  String _bp = 'mediumHandset';
  late Future<void> _openPushes;
  List<Map<String, dynamic>> dataSort = [];
  final ValueNotifier<bool> _onTaping = ValueNotifier(false);

  @override
  void dispose() {
    _scrollEnProceso.dispose();
    _onTaping.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    _bp = globals.getDeviceFromConstraints(widget.constraints);

    return FutureBuilder(
      future: _openPushes,
      builder: (_, AsyncSnapshot snapshot) {

        if(snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              RepoTitulo(
                titulo:  (kIsWeb) ? 'LISTA EN PROCESAMIENTO' : 'EN PROCESAMIENTO',
                onTap: (int salir) => widget.onTap(salir)
              ),
              Expanded(
                child: ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: (dataSort.length != widget.lstKeys.length)
                    ? _buildDataSord()
                    : _drawList()
                )
              )
            ],
          );
        }

        return const SizedBox();
      }
    );
  }

  ///
  Widget _buildDataSord() {

    return FutureBuilder(
      future: _hidratarData(),
      builder: (_, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          return _drawList();
        }
        return const SizedBox(); 
      }
    );
  }

  ///
  Widget _drawList() {

    return ListView.builder(
      controller: _scrollEnProceso,
      shrinkWrap: true,
      itemCount: dataSort.length,
      itemBuilder: (_, index) {
        return _itemRepo(index);
      },
    );
  }

  ///
  Future<void> _hidratarData() async {

    dataSort = [];
    for (var i = 0; i < widget.lstKeys.length; i++) {
      final data = await _dsRepo.getOrdenFromEntityToMapBy(0, keyOrden: widget.lstKeys[i]);
      dataSort.add(data);
      // datos['key${widget.lstKeys[i]}-${data['statusId']}'] = data;
      // status.add(data['statusId']);
    }

    // status.sort();
    // List<int>? statusSort = List<int>.from(status.reversed);
    // status = null;
    
    // for (var i = 0; i < statusSort.length; i++) {
    //   for (var x = 0; x < widget.lstKeys.length; x++) {

    //     bool metemos = true;
    //     String key = 'key${widget.lstKeys[x]}-${statusSort[i]}';
    //     if(datos.containsKey(key)) {
    //       if(dataSort.isNotEmpty) {
    //         final has = dataSort.firstWhere((elem) => elem['key'] == widget.lstKeys[x], orElse: () => {});
    //         if(has.isNotEmpty) {
    //           metemos = false;
    //         }
    //       }
    //       if(metemos) {
    //         datos[key]!['key'] = widget.lstKeys[x];
    //         dataSort.add(datos[key]!);
    //         break;
    //       }
    //     }
    //   }
    // }
  }

  ///
  Widget _itemRepo(int index) {

    return InkWell(
      onTap: () async {
        _dsRepo.fromIdRepo = 'proceso';
        _dsRepo.idRepoMainSelectCurrent = dataSort[index]['idMain'];
        _onTaping.value = !_onTaping.value;
        if(_bp == 'mediumHandset') {
          widget.onTap(dataSort[index]['key']);
        }else{
          Future.delayed(const Duration(milliseconds: 100), (){
            context.read<PestaniasProv>().pestaniaSelect = 'Cotizaciones';
          });
        }
      },
      child: ValueListenableBuilder(
        valueListenable: _onTaping,
        builder: (_, ref,__) {
          return ReposCard(
            repoMain: dataSort[index],
            constraints: widget.constraints,
            pieData: _getDataPie(index),
          );
        },
      )
    );
  }

  ///
  Map<String, dynamic>? _getDataPie(int index) {

    Map<String, dynamic>? hasPie;
    // BLOQUE QUE INDICA SI UNA SOLICITUD YA CUENTA CON ALGUNA RESPUESTA
    // ver si hay un registros de tipo ::resp::
    
    return hasPie;
  }


}