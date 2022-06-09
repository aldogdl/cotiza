import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';

import 'auto_ui.dart';
import '../varios_widgets.dart';
import '../../pages/home/data_shared/ds_repo.dart';
import '../../entity/orden.dart';
import '../../entity/marcas.dart';
import '../../entity/modelos.dart';
import '../../repository/automovil.dart';
import '../../repository/repos_repository.dart';

class AutoController extends StatefulWidget {

  final ValueChanged<dynamic> isFinish;
  final ValueChanged<void> onClose;
  const AutoController({
    Key? key,
    required this.isFinish,
    required this.onClose,
  }) : super(key: key);

  @override
  State<AutoController> createState() => AutoControllerState();
}

class AutoControllerState extends State<AutoController> {

  final VariosWidgets variosWidgets = VariosWidgets();
  final AutomovilRepository _autoEm = AutomovilRepository();
  final RepoRepository _repoEm = RepoRepository();
  final Globals globals = getSngOf<Globals>();
  final DsRepo dsRepo = getSngOf<DsRepo>();

  final ScrollController ctrScroll = ScrollController();
  final ScrollController ctrScrollRecent = ScrollController();
  final TextEditingController ctrBsk = TextEditingController();
  
  final FocusNode focusBsk = FocusNode();

  int anio = -1;
  int idMarcaSelect = -1;
  int idModelosSelect = -1;
  double widthMin = 0;
  String logoSelect = '0';
  String tipoLista = 'load';
  String msgLoad = 'Cargando Items';
  String keyboardCurrent = 'txt';
  bool isNac = true;
  bool showBtnClose = true;
  bool showRecientes = false;
  List<int> copyAnios = [];
  List<dynamic> itemsFiltrados = [];
  ValueNotifier<String> modeloSelect = ValueNotifier('MODELO');

  Color bgLstAuto = Colors.grey[100]!;
  late Future _initWidget;

  @override
  void initState() {
    _initWidget = _iniciandoWidget();
    widthMin = globals.minIzq;    
    super.initState();
  }

  @override
  void dispose() {

    ctrBsk.dispose();
    focusBsk.dispose();

    ctrScroll.dispose();
    ctrScrollRecent.dispose();
    
    dsRepo.marcas.compact();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _initWidget,
      builder: (_, AsyncSnapshot snap) {
        if(snap.connectionState == ConnectionState.done) {
          return AutoUI(context, this);
        }
        return const SizedBox();
      },
    );
  }

  ///
  void buscarItem(String busk) async {

    if(showRecientes) {
      showRecientes = false;
    }
    busk = busk.toUpperCase();
    itemsFiltrados.clear();

    if(tipoLista == 'marcas') {
      for (var i = 0; i < dsRepo.marcas.values.length; i++) {
        if( dsRepo.marcas.get(i)!.marca.startsWith(busk) ) {
          itemsFiltrados.add(dsRepo.marcas.get(i)!);
        }
      }
    }

    if(tipoLista == 'modelos') {
      for (var i = 0; i < dsRepo.modelos.values.length; i++) {
        if(dsRepo.modelos.get(i)!.modelo.startsWith(busk) && dsRepo.modelos.get(i)!.idMrk == idMarcaSelect ) {
          itemsFiltrados.add(dsRepo.modelos.get(i));
        }
      }
    }

    if(tipoLista == 'anios') {
      for (var i = 0; i < copyAnios.length; i++) {
        if( '${copyAnios[i]}'.contains(busk) ) {
          itemsFiltrados.add(copyAnios[i]);
        }
      }
    }
    if(mounted) {
      setState(() {});
    }
  }

  ///
  void seleccionarMarca(int index) async {

    idMarcaSelect = itemsFiltrados[index].id;
    logoSelect    = (itemsFiltrados[index].logo == '0')
      ? 'no-logo.png' : itemsFiltrados[index].logo;

    itemsFiltrados.clear();
    await _getModelos();
    await _switchKeyBoard('txt');
  }

  ///
  void seleccionarModelo(int index) async {
    
    idModelosSelect = itemsFiltrados[index].id;
    modeloSelect.value = itemsFiltrados[index].modelo;

    itemsFiltrados.clear();
    await _getAnios();
    await _switchKeyBoard('num');
  }

  ///
  void seleccionarAnio(int index) async {

    focusBsk.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    await Future.delayed(const Duration(milliseconds: 350));
    anio = itemsFiltrados[index];
    await buildOrdenToServer();
  }

  ///
  void backToMarcas() async {

    itemsFiltrados.clear();
    tipoLista = 'marcas';
    for (var i = 0; i < dsRepo.marcas.values.length; i++) {
      itemsFiltrados.add(dsRepo.marcas.get(i)!);
    }
    await _switchKeyBoard('txt');
  }

  ///
  void backToModelos() async {

    itemsFiltrados.clear();
    tipoLista = 'load';
    
    await _getModelos();
    await _switchKeyBoard('txt');
  }

  ///
  String getMarcaCurrent({bool fromUI = false, int idMrk = 0}) {

    int evaluar = (fromUI) ? idMrk : idMarcaSelect;
    if(evaluar != -1) {
      final mk = getMarcaByID(evaluar);
      if(mk != null) {
        return mk.marca;
      }
    }
    return 'MARCA';
  }

  ///
  String getStrModelo(int idModelo) {

    if(idModelo != -1) {
      Modelos md = dsRepo.modelos.values.firstWhere(
        (mdl) => mdl.id == idModelo,
        orElse: () => Modelos(0, 0, '')
      );
      if(md.id != 0) {
        return md.modelo;
      }
    }
    return 'MODELOS';
  }

  ///
  String getNacionalidadCurrent({bool fromUI = false, bool isNacUI = true}) {

    bool evaluar = (fromUI) ? isNacUI : isNac;
    if(evaluar) {
      return 'NACIONAL';
    }
    return 'IMPORTADO';
  }

  ///
  void setNacionalidad(bool? isNAC) {
    if(isNAC != null) {
      isNac = isNAC;
      if(mounted) {
        setState(() {});
      }
    }
  }

  ///
  Marcas? getMarcaByID(int idMarca) {

    Marcas mk = dsRepo.marcas.values.firstWhere(
      (mrk) => mrk.id == idMarca,
      orElse: () => Marcas(0, '0', '0')
    );
    if(mk.id != 0) {
      return  mk;
    }
    return null;
  }

  ///
  Future<void> _iniciandoWidget() async {

    await dsRepo.initAutos();
    for (var i = 0; i < dsRepo.marcas.length; i++) {
      itemsFiltrados.add(dsRepo.marcas.get(i)!);
    }
    DateTime hoy = DateTime.now();
    anio = hoy.year;
    if(itemsFiltrados.isNotEmpty) {
      tipoLista = 'marcas';
    }
  }

  ///
  Future<void> _getModelos() async {

    if(dsRepo.modelos.values.isEmpty) {
      await _fromHttpGetModelos();
    }else{
      
      for (var i = 0; i < dsRepo.modelos.values.length; i++) {
        if(dsRepo.modelos.get(i)!.idMrk == idMarcaSelect) {
          itemsFiltrados.add(dsRepo.modelos.get(i));
        }
      }

      if(itemsFiltrados.isEmpty) {
        await _fromHttpGetModelos();
      }else{
        tipoLista = 'modelos';
        ctrBsk.text = '';
        focusBsk.requestFocus();
      }
    }
  }

  ///
  Future<void> _fromHttpGetModelos() async {

    tipoLista = 'load';
    if(mounted) {
      setState(() {});
    }
    await _autoEm.getModelosByIdMarca(idMarcaSelect);
    if(!_autoEm.result['abort']) {
      List<Map<String, dynamic>>? mods = List<Map<String, dynamic>>.from(_autoEm.result['body']);
      if(mods.isNotEmpty) {
        for (var i = 0; i < mods.length; i++) {
          final m = Modelos(mods[i]['md_id'], mods[i]['mrk_id'], mods[i]['md_nombre']);
          dsRepo.modelos.add(m);
          itemsFiltrados.add(m);
        }
        Map<dynamic, Marcas>? misMarcas = dsRepo.marcas.toMap();
        misMarcas.forEach((key, mrk) async {
          if(mrk.id == idMarcaSelect) {
            mrk.cantMods = itemsFiltrados.length;
            await mrk.save();
          }
        });
        mods = null;
        misMarcas = null;
      }
      _autoEm.cleanResult();
      ctrBsk.text = '';
      focusBsk.requestFocus();
      tipoLista = 'modelos';
      if(mounted) {
        setState(() {});
      }
    }
  }

  ///
  Future<void> _getAnios() async {

    DateTime anioCurrent = DateTime.now();
    for (var i = anioCurrent.year; i > 1930; i--) {
      itemsFiltrados.add(i);
    }
    tipoLista = 'anios';
    copyAnios = List<int>.from(itemsFiltrados);
    ctrBsk.text = '';
    focusBsk.requestFocus();
  }

  ///
  Future<void> _switchKeyBoard(String changeTo) async {

    if(keyboardCurrent != changeTo) {
      keyboardCurrent = changeTo;
      focusBsk.unfocus();
      await Future.delayed(const Duration(milliseconds: 350));
      if(mounted) {
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => focusBsk.requestFocus(),
          );
        });
      }
    }else{
      setState(() {});
    }
  }

  ///
  Future<void> buildOrdenToServer() async {

    itemsFiltrados.clear();
    tipoLista = 'sending';
    showBtnClose = false;

    if(mounted) {
      setState(() {});
    }

    await dsRepo.openBoxUserAdmin();
    Orden orden = Orden();

    orden.id    = 0;
    orden.own   = dsRepo.user.getAt(0)!.id;
    orden.marca = idMarcaSelect;
    orden.modelo= idModelosSelect;
    orden.anio  = anio;
    orden.isNac = isNac;

    // Construimos la bolsa bacia para colocar los datos de las piezas
    await _repoEm.buildNewOrden(orden.toServer());

    if(!_repoEm.result['abort']) {
      if(_repoEm.result['body'].containsKey('id')) {

        orden.id        = _repoEm.result['body']['id'];
        orden.createdAt = DateTime.parse(_repoEm.result['body']['created_at']['date']);

        if(mounted) { setState(() { msgLoad = 'Espere un Momento'; }); }

        await dsRepo.orden.add(orden);
        widget.isFinish(dsRepo.orden.values.last.key);
        
      }else{
        tipoLista = 'errFromServer';
      }
      _repoEm.cleanResult();

    }else{
      tipoLista = 'errFromServer';
      showBtnClose = true;
      if(mounted) {
        setState(() {});
      }
    }
  }

  ///
  void close() => widget.onClose(null);

}