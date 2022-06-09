import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/scroll_config.dart';

import 'repo_titulo.dart';
import 'repos_card.dart';
import '../data_shared/ds_repo.dart';
import '../../../providers/pestanias_prov.dart';

class SeccLstPendientes extends StatefulWidget {

  final BoxConstraints constraints;
  final List<int> lstKeys;
  final ValueChanged<int> onTap;
  const SeccLstPendientes({
    Key? key,
    required this.constraints,
    required this.lstKeys,
    required this.onTap
  }) : super(key: key);

  @override
  State<SeccLstPendientes> createState() => _SeccLstPendientesState();
}

class _SeccLstPendientesState extends State<SeccLstPendientes> {

  final Globals globals = getSngOf<Globals>();
  final DsRepo _dsRepo = getSngOf<DsRepo>();
  final ScrollController _scrollEnProceso = ScrollController();
    
  String _bp = 'mediumHandset';
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

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Column(
        children: [
          RepoTitulo(
            titulo: 'MIS PENDIENTES',
            onTap: (int salir) => widget.onTap(salir)
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollEnProceso,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.lstKeys.length,
              itemBuilder: (_, index) => _itemRepo(index),
            ),
          )
        ],
      )
    );
  }

  ///
  Widget _itemRepo(int index) {

    final futureThis = _dsRepo.getOrdenFromEntityToMapBy(0, keyOrden: widget.lstKeys[index]);

    return FutureBuilder<Map<String, dynamic>>(
      future: futureThis,
      builder: (context, AsyncSnapshot repoMap) {

        final pesta = context.read<PestaniasProv>();
        if(repoMap.connectionState == ConnectionState.done) {
          if(repoMap.hasData) {

            return InkWell(
              onTap: () async {                
                _onTaping.value = !_onTaping.value;
                _dsRepo.fromIdRepo = 'pendientes';
                if(_bp == 'mediumHandset') {
                  _dsRepo.idRepoMainSelectCurrent = repoMap.data['idMain'];
                  widget.onTap(widget.lstKeys[index]);
                }else{
                  await _dsRepo.isSameRepoSelect(context, idOrdenS: repoMap.data['idMain']);
                  pesta.pestaniaSelect = 'Cotizar';
                  widget.onTap(widget.lstKeys[index]);
                }
              },
              child: ValueListenableBuilder<bool>(
                valueListenable: _onTaping,
                builder: (_, ref,__) {
                  
                  return ReposCard(
                    repoMain: repoMap.data,
                    constraints: widget.constraints,
                  );
                },
              )
            );
          }
        }
        return const SizedBox();
      },
    );
  }

}