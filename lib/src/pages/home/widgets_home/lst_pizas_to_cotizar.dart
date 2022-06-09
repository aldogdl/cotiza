import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';

import 'tile_pza_before_cot.dart';
import '../data_shared/ds_repo.dart';
import '../../../entity/orden_piezas.dart';
import '../../../repository/repos_repository.dart';
import '../../../providers/pzas_to_cotizar_prov.dart';
import '../../../providers/btn_send_cotizacion_prov.dart';
import '../../../widgets/varios_widgets.dart';

class LstPiezasToCotizar extends StatefulWidget {

  final ValueChanged<int> onTapForEdit;
  final ValueChanged<int> onDelete;
  final ValueChanged<Map<String, int>> onSaved;
  const LstPiezasToCotizar({
    Key? key,
    required this.onTapForEdit,
    required this.onDelete,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<LstPiezasToCotizar> createState() => LstPiezasToCotizarState();
}

class LstPiezasToCotizarState extends State<LstPiezasToCotizar> {

  final globals = getSngOf<Globals>();
  final refCotiz= getSngOf<RefCotiz>();
  final dsRepo  = getSngOf<DsRepo>();
  final VariosWidgets variosWidgets = VariosWidgets();
  final RepoRepository _repoEm = RepoRepository();

  late PzasToCotizarProv _prov;
  late Future<void> _inicializarWidget;
  final ScrollController _scrolPzas = ScrollController();

  bool isInit = false;

  @override
  void initState() {
    _inicializarWidget = _initWidget();
    super.initState();
  }

  @override
  void dispose() {
    _scrolPzas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _inicializarWidget,
      builder: (_, AsyncSnapshot snapshot) {

        return (snapshot.connectionState == ConnectionState.done)
          ? _buildListaPiezas()
          : _containerWait(const Text('Cargando...'));
      }
    );
  }

  ///
  Future<void> _initWidget() async {

    if(!isInit) {
      isInit = true;
      _prov = context.read<PzasToCotizarProv>();
    }
    dsRepo.openBoxOrdenPzas().then((_) async {
      await dsRepo.putNewPiezasInProvider(context);
    });
  }

  ///
  Widget _buildListaPiezas() {

    return Selector<PzasToCotizarProv, List<int>>(
      selector: (_, provi) => provi.keysPiezas,
      builder: (_, lst, __) {

        if(lst.isEmpty) {
          return _containerWait( Icon(Icons.extension_off, color: Colors.grey[200]!, size: 150) );
        }

        return Column(
          children: [
            StreamBuilder(
              stream: _savePiezas(),
              builder: (_, __) => const SizedBox(),
            ),
            if(context.watch<BtnSendCotizacionProv>().activLoaderSend)
              const LinearProgressIndicator()
            else
              const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                controller: _scrolPzas,
                itemCount: lst.length,
                itemBuilder: (_, int indexKey) {

                  OrdenPiezas? pieza = dsRepo.ordenPzas.get(lst[indexKey]);

                  if(pieza == null) {  return const SizedBox(); }

                  return TilePzaBeforeCot(
                    pieza: pieza,
                    onAction: (accion) async {
                      if(accion['onpress'] == 'del') {
                        await _eliminarPiezaFromModal(accion['keyPieza']);
                      }else{
                        _prov.changeDataWith(accion['keyPieza'], false);
                        refCotiz.keyPiezaEdit = accion['keyPieza'];
                        refCotiz.isEditWeb = true;
                        widget.onTapForEdit(refCotiz.keyPiezaEdit);
                      }
                    },
                  );
                },
              ),
            )
          ],
        );
      }
    );
  }

  ///
  Widget _containerWait(Widget child) => SizedBox.expand( child: Center( child: child ) );

  ///
  Future<void> _eliminarPiezaFromModal(int keyPieza) async {

    final btn = context.read<BtnSendCotizacionProv>();
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

        btn.setActiveLoaderSend(true);
        bool res = await _repoEm.deletePiezaAntesDeSave(pza.id);
        
        if(res) {
          await pza.delete();
          await dsRepo.ordenPzas.compact();
          _prov.hasFotos = false;
          refCotiz.keyPiezaEdit = -1;
          refCotiz.isEditWeb = false;
          _prov.buildPzaNewOfOrden(idOrd: dsRepo.idRepoMainSelectCurrent);
          widget.onDelete(keyPieza);
        }
      }
    }
  }

  ///
  Stream<void> _savePiezas() async* {

    await for (Map<String, int> keyPza in _repoEm.sendPzaStream(_prov.pzasToSend)) {
      if(keyPza['key'] != -1) {
        await _prov.changeDataWith(keyPza['key']!, true);
        widget.onSaved(keyPza);
        setState(() {});
      }
    }
  }

}