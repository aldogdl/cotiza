import 'package:autoparnet_cotiza/src/pages/home/widgets_home/frm_cotiza_modal_pzas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cron/cron.dart';

import 'package:autoparnet_cotiza/vars/vals_constantes.dart';

import 'titulo_page.dart';
import 'frm_cotiza_fotos.dart';
import 'frm_cotiza_campos.dart';
import 'frm_cotiza_txt_fotos.dart';
import 'frm_cotiza_btn_fotos_ok.dart';
import 'frm_cotiza_modal_fotos_incomplets.dart';
import '../piezas_add_web_ui.dart';
import '../data_shared/ds_repo.dart';
import '../../../entity/orden.dart';
import '../../../entity/piezas_reg.dart';
import '../../../entity/orden_piezas.dart';
import '../../../repository/repos_repository.dart';
import '../../../providers/check_login.dart';
import '../../../providers/btn_send_cotizacion_prov.dart';
import '../../../providers/pzas_to_cotizar_prov.dart';
import '../../../widgets/get_fotos/get_fotos_widget.dart';
import '../../../widgets/get_fotos/singleton/picker_pictures.dart';
import '../../../widgets/varios_widgets.dart';
import '../../../../vars/globals.dart';
import '../../../../vars/ref_cotiz.dart';
import '../../../../vars/scroll_config.dart';
import '../../../../config/sng_manager.dart';


class FrmCotiza extends StatefulWidget {

  final BoxConstraints constraints;
  final ValueChanged<int> onFinish;
  final ValueChanged<bool> onChangeScreen;
  const FrmCotiza({
    required this.constraints,
    required this.onFinish,
    required this.onChangeScreen,
    Key? key
  }) : super(key: key);

  @override
  State<FrmCotiza> createState() => _FrmCotizaState();
}


class _FrmCotizaState extends State<FrmCotiza> {

  final _ctrScroll = ScrollController();
  final globals = getSngOf<Globals>();
  final refCotz = getSngOf<RefCotiz>();
  final dsRepo  = getSngOf<DsRepo>();
  final picktures = getSngOf<PickerPictures>();
  final variosWidgets = VariosWidgets();
  final _repoEm = RepoRepository();

  final ValueNotifier<String> _sharedFotosMsg = ValueNotifier<String>('Revisando en 5');

  late final Widget sp;
  late final PzasToCotizarProv pzaCurrent;
  late Cron cron;

  int _sharedFotos = 0;
  int _segundoShared = 5;
  double pfrm = 0;
  bool _cancelCron = false;
  bool _blockMethod = false;
  bool _makeFncSend = false;
  bool _isInit = false;
  bool isPressTerminar = false;
  bool _isShowModalTerminar = false;
  String _tipoCheck = '';
  String _bp = 'mediumHandset';
  String _revisaFotosDesde = 'add';
  List<Map<String, dynamic>> piezasRegs = [];
  List<String> fotosYaEnviadas = [];

  @override
  void initState() {

    refCotz.keyPiezaEdit = -1;
    sp = const SizedBox(height: ValoresConstantes.altoSp);
    _bp = globals.getDeviceFromConstraints(widget.constraints);
    // Revisamos que exista una orden main seleccionado.
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }

  @override
  void dispose() {

    _ctrScroll.dispose();
    pzaCurrent.pzaOfOrdenCurrent = {};
    picktures.idOrden = -1;
    picktures.idPiezaTmp = '';
    if(mounted){
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    BoxDecoration? boxDecora = BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.black,
          Colors.black,
          Colors.black,
          Colors.grey[800]!
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
      )
    );

    if(!_isInit) {
      _isInit = true;
      pzaCurrent = context.read<PzasToCotizarProv>();
    }
    pfrm = (_bp == 'mediumHandset') ? 20 : 0;
    if(_bp != 'mediumHandset' && kIsWeb) {
      boxDecora = null;
    }

    return WillPopScope(
      onWillPop: () async {
        if(!pzaCurrent.hasFotos){
          return Future.value(true);
        }else{
          pzaCurrent.hasFotos = false;
        }
        return Future.value(false);
      },
      child: Container(
        padding: EdgeInsets.only(bottom: pfrm),
        width: MediaQuery.of(context).size.width,
        decoration: boxDecora,
        child: SizedBox.expand(
          child: _body(),
        )
      ),
    );
  }

  ///
  Widget _body() {

    if(!pzaCurrent.hasFotos) {
      Future.delayed(const Duration(milliseconds: 350), (){
        widget.onChangeScreen(pzaCurrent.hasFotos);
      });
    }

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: ListView(
        controller: _ctrScroll,
        shrinkWrap: true,
        children: [
          TituloPage(
            icono: Icons.text_snippet_outlined,
            tamRadius: (_bp == 'mediumHandset') ? 0 : 10,
          ),
          const Divider(),
          Selector<PzasToCotizarProv, bool>(
            selector: (_, provi) => provi.hasFotos, 
            builder: (_, hFotos, child) {

              if(!hFotos) {
                return (kIsWeb) ? _putFotosInWeb() : _putFotosInMovil();
              } else {

                return (kIsWeb)
                ? _frm()
                : FutureBuilder(
                  future: _initWidget(null),
                  builder: (_, AsyncSnapshot snap) {
                    if(snap.connectionState == ConnectionState.done) {
                      return Column(
                        children: [
                          FutureBuilder(
                            future: _comprimirAndSendImgs(),
                            builder: (_, __) => const SizedBox()
                          ),
                          _frm()
                        ],
                      );
                    }
                    return child!;
                  },
                );
              }
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              child: const Center(child: CircularProgressIndicator()),
            ),
          )
        ]
      ),
    );
  }

  ///
  Widget _frm() {

    return FrmCotizaCampos(
      idOrden: dsRepo.idRepoMainSelectCurrent,
      brackPoint: _bp,
      isMovil: (_bp == 'mediumHandset') ? true : false,
      padding: (_bp == 'mediumHandset') ? 0 : pfrm,
      sp: ValoresConstantes.altoSp,
      showFotos: (kIsWeb && pzaCurrent.hasFotos) ? true : false,
      onEditFotos: (_) async {
        
        pzaCurrent.piezaOfOrdenCurrent['fotos'] = await _isAllFotosSended();
        if(pzaCurrent.piezaOfOrdenCurrent['fotos'].isNotEmpty) {
          await _showModalFotosNoSend(
            List<String>.from(pzaCurrent.piezaOfOrdenCurrent['fotos']),
            onlyCheck: true
          );
        }else{
          pzaCurrent.hasFotos = false;
        }
      },
      onTapTerminar: (_) async => _onPressBtnTerminar('normal'),
      onTapAddmore: (_) async => await _agregarMasPiezas('add'),
      onScrollMoveTo: (_) => _ctrScroll.position.moveTo(_ctrScroll.position.maxScrollExtent),
    );
  }

  ///
  Widget _putFotosInWeb() {

    double sizeTitulo = (_bp != 'mediumHandset') ? 15 : 19;
    double sizeParafo = (_bp != 'mediumHandset') ? 14 : 17;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: (_bp == 'mediumHandset') ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FrmCotizaTxtFotos(
            styleTitulo: globals.styleText(sizeTitulo, Colors.green, false),
            styleParrafo: globals.styleText(sizeParafo, Colors.grey, false)
          ),
          ..._instFotosEnPC(),
          sp,
          Center(
            child: GetFotosWidget(
              cantMax: picktures.maxPermitidas,
              theme: 'dark',
              idOrden: dsRepo.idRepoMainSelectCurrent,
              constraints: widget.constraints,
              onFinish: (imgs){},
            ),
          ),
          const SizedBox(height: 8),
          if(_sharedFotos == 3)
            _waitFotos()
          else
            _instFotosFromCelAndQr(),
          const SizedBox(height: 15),
          FrmCotizaBtnFotosOk(
            idOrden: dsRepo.idRepoMainSelectCurrent,
            cantFotos: pzaCurrent.keysPiezas.length,
            btnStyleListo: globals.styleText(
              (_bp == 'mediumHandset') ? 18 : 15,
              Colors.white, false
            ),
            showBtnVerPiezas: (pzaCurrent.keysPiezas.isNotEmpty && !kIsWeb && refCotz.keyPiezaEdit == -1)
            ? true : false,
            btnStyleVerPiezas: globals.styleText(
              (_bp == 'mediumHandset') ? 18 : 15,
              Colors.white, false
            ),
            onPressBtnListo: (_) async => await _onPressBtnListo(),
            onPressBtnVerPiezas: (_) async => await _onPressBtnTerminar('fotos')
          ),
        ],
      ),
    );
  }

  ///
  Widget _putFotosInMovil() {

    if(isPressTerminar) {
      Future.delayed(const Duration(milliseconds: 200), (){
        _showModalTerminarSol();
      });
    }

    return FrmCotizaFotos(
      idOrden: dsRepo.idRepoMainSelectCurrent,
      globals: globals,
      brackPoint: _bp,
      picktures: picktures,
      constraints: widget.constraints,
      showBtnVerPiezas: (pzaCurrent.keysPiezas.isNotEmpty && !kIsWeb && refCotz.keyPiezaEdit == -1)
      ? true : false,
      onPressBtnVerPiezas: (_) async => _onPressBtnTerminar('fotos'),
      onPressBtnListo: (_) async => await _onPressBtnListo(),
      cantFotos: pzaCurrent.keysPiezas.length,
      sp: sp,
    );
  }

  ///
  Widget _waitFotos() {

    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'MUY BIEN!!, ESTAMOS EN ESPERA',
            textScaleFactor: 1,
            style: globals.styleText(14, Colors.blue, false),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<String>(
            valueListenable: _sharedFotosMsg,
            builder: (_, val, __) {
              return Text(
                val,
                textScaleFactor: 1,
                style: globals.styleText(14, Colors.grey, false),
              );
            }
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.orange)
            ),
            onPressed: () {
              _cancelCron = true;
            },
            child: Text(
              ' CANCELAR OPERACIÓN ',
              textScaleFactor: 1,
              style: globals.styleText(
                (_bp == 'mediumHandset') ? 18 : 15,
                Colors.white, false
              ),
            )
          )
        ],
      ),
    );
  }

  /// Instrucciones
  List<Widget> _instFotosEnPC() {

    return [
      Text(
        '1.- Ház click en el contenedor superior para abrir tu '
        'explorador de archivos, selecciona tus fotos y preciona '
        'el Boton de abrir. ',
        textScaleFactor: 1,
        style: globals.styleText(14, Colors.grey, false),
      ),
      const SizedBox(height: 8),
      Text(
        '2.- Si esta abieta la ventana de imágenes '
        'selecciona hasta ${picktures.maxFotos} fotos y '
        'arrastralas al contenedor. ',
        textScaleFactor: 1,
        style: globals.styleText(14, Colors.grey, false),
      ),
    ];
    
  }

  /// Instrucciones
  Widget _instFotosFromCelAndQr() {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _showQr(),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if(_sharedFotos == 2)
                    ...[
                      Text(
                        '1.- Leé el Código QR desde tu aplicación móvil '
                        'de AutoparNet Cotiza.',
                        textScaleFactor: 1,
                        style: globals.styleText(14, Colors.blue, false),
                      ),
                    ]
                  else
                    ...[
                      Text(
                        'El sistema preparará todo lo necesario para entablar '
                        'comunicación con tu aplicación Móvil de Autoparnet COTIZA.',
                        textScaleFactor: 1,
                        style: globals.styleText(14, Colors.grey, false),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cuando todo esté listo, continua con las instrucciones '
                        'que se mostrarán en pantalla.',
                        textScaleFactor: 1,
                        style: globals.styleText(14, Colors.grey, false),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '1.- Presiona sobre el QR que esta a la Izquiera.',
                        textScaleFactor: 1,
                        style: globals.styleText(14, Colors.blue, false),
                      ),
                    ],
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  ///
  Widget _showQr() {

    return ValueListenableBuilder(
      valueListenable: picktures.totalFotosSelected,
      builder: (_, int tot, __) {

        int faltan = picktures.maxFotos - tot;
        final idTmpImgQr = '${picktures.idOrden}-$faltan-${picktures.idPiezaTmp}';

        return Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.all(5),
          child: Center(
            child: Stack(
              children: [
                Positioned.fill(
                  child: QrImage(
                    data: idTmpImgQr,
                    version: QrVersions.auto,
                    size: 150,
                    padding: const EdgeInsets.all(0),
                  ),
                ),
                if(_sharedFotos == 0)
                  Positioned(
                    top: 0, left: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          color: Colors.white.withOpacity(0.9),
                          child: IconButton(
                            onPressed: () => _getSharedFotosFromDevice(),
                            icon: const Icon(Icons.refresh, size: 70, color: Colors.grey)
                          ),
                        ),
                      ],
                    ),
                  ),
                if(_sharedFotos == 1)
                  Positioned(
                    top: 0, left: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          color: Colors.white.withOpacity(0.9),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 30, height: 30,
                                  child: CircularProgressIndicator(),
                                ),
                                Text(
                                  'Preparando...',
                                  textScaleFactor: 1,
                                  style: globals.styleText(14, Colors.green, false),
                                )
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            )
          )
        );
      }
    );
  }


  // -------------------------- Controlador --------------------------------


  ///
  Future<void> _initWidget(_) async {

    if(_blockMethod){ return; }
    _blockMethod = true;
    final provUser = context.read<CheckLoginProvider>();
    bool isOk = await _initWidgetCheckData();

    if(isOk) {
      piezasRegs = await _repoEm.getPiezasRegistradas();
      picktures.tokenServer = await provUser.isTokenCaducado();
      
      picktures.idOrden = dsRepo.idRepoMainSelectCurrent;

      pzaCurrent.buildPzaNewOfOrden(idOrd: dsRepo.idRepoMainSelectCurrent);
      picktures.idPiezaTmp = '${pzaCurrent.piezaOfOrdenCurrent['id']}';
    }
  }

  ///
  Future<bool> _initWidgetCheckData() async {

    bool isAlert = false;
    String msgMain = '';
    String msgSec  = '';

    msgMain = 'El sistema no detectó ningún Registro';
    msgSec  = 'Por favor, preciona el Boton de Cotizar en la pantalla principal para comenzar con una Solicitud';

    if(dsRepo.idRepoMainSelectCurrent == 0) {
      isAlert = true;
    }else{

      await dsRepo.openBoxOrdenPzas();
      await dsRepo.openBoxPzaReg();
    
      if(dsRepo.orden.isEmpty) {
        isAlert = true;
      }else{

        Iterable<Orden>? existOrden = dsRepo.orden.values.where((main) => main.id == dsRepo.idRepoMainSelectCurrent);
        if(existOrden.isEmpty) {
          isAlert = true;
          msgMain = 'No se pudo econtrar el Registro';
          msgSec  = 'El sistema no encontró el Registro con el ID: ${dsRepo.idRepoMainSelectCurrent}, inténtalo nuevamente.';

        }else{

          if(existOrden.length > 1) {
            isAlert = true;
            msgMain = 'Redundancia en tus Registros';
            msgSec  = 'El sistema encontró que cuentas con varios registro con el ID: ${dsRepo.idRepoMainSelectCurrent}.\nElimina uno de ellos antes de continuar';
          }else{

            final orden = dsRepo.orden.get(existOrden.first.key);
            if(orden != null) {
              existOrden = null;
              if(orden.id != dsRepo.idRepoMainSelectCurrent) {
                // Alerta Error inesperado, los ids no coinciden, se selecciono otro objeto
                isAlert = true;
                msgMain = 'Error Inesperado';
                msgSec  = 'El sistema selecciono un Registro diferente al solicitado con el ID: ${dsRepo.idRepoMainSelectCurrent}.\nInténtalo nuevamente';
              }
            }
          }
        }
      }
    }

    if(isAlert) {

      variosWidgets.dialog(
        cntx: context,
        tipo: 'entendido',
        icono: Icons.data_saver_off,
        colorIcon: Colors.orange,
        titulo: msgMain,
        textMain: msgSec
      ).then((_){
        if(!kIsWeb) { Navigator.of(context).pop(); }
      });
      return false;
    }

    return true;
  }

  ///
  Future<void> _onPressBtnTerminar(String from) async {
    isPressTerminar = true;
    await _terminarSolicitud(from: from);
  }

  ///
  Future<void> _onPressBtnListo() async {

    if(picktures.fotosFromServer.isEmpty && picktures.imageFileList.isEmpty) {

      if(refCotz.keyPiezaEdit != -1 && picktures.fotosFromServer.isNotEmpty) {
        pzaCurrent.hasFotos = true;
      }else{
        variosWidgets.message(
          context: context,
          msg: 'AL MENOS COLOCA UNA FOTOGRAFÍA COMO REFERENCIA.\nRecuerda que nuestro objetivo es darte el mejor servicio.'
        );
      }

    }else{
      _cancelCron = true;
      pzaCurrent.hasFotos = true;
    }
  }

  ///
  Future<bool> _agregarMasPiezas(String from) async {

    late OrdenPiezas ordenPiezas;
    var pieza = Map<String, dynamic>.from(pzaCurrent.piezaOfOrdenCurrent);

    if(refCotz.keyPiezaEdit == -1) {
      await _registrarPiezaName(pieza);
      // Revisamos que todas las fotos ya se hallan enviado.
      pieza['fotos'] = await _isAllFotosSended();
      if(from != 'add') { return false; }
      if(pieza['fotos'].isNotEmpty) {
        await _showModalFotosNoSend(List<String>.from(pieza['fotos']));
        return false;
      }else{
        pieza['fotos'] = List<String>.from(fotosYaEnviadas);
        fotosYaEnviadas = [];
      }
    }

    if(pieza['piezaName'].isEmpty){ return false; }

    ordenPiezas = OrdenPiezas()..fromJson(pieza);
    if(refCotz.keyPiezaEdit != -1) {
      await dsRepo.ordenPzas.put(refCotz.keyPiezaEdit, ordenPiezas);
    }else{
      await dsRepo.ordenPzas.add(ordenPiezas);
    }

    if(!mounted) return false;
    await dsRepo.putNewPiezasInProvider(context);
    if(mounted) {
      // Usamos este metodo para cambiar el boton de...
      // PestaniasProv :: pestaniaSelect :: Cotizar
      widget.onChangeScreen(true);
      await dsRepo.putSttOrdenAndBtnSendActive(context);
    }

    if(refCotz.keyPiezaEdit != -1) {
      await pzaCurrent.changeDataWith(refCotz.keyPiezaEdit, false);
    }
    if(_bp == 'mediumHandset') { await _sendPzaToServer(); }

    await _cleanScreen();
    if(isPressTerminar) {
      _terminarSolicitud(from: 'add');
    }
    pzaCurrent.hasFotos = false;
    return true;
  }

  ///
  Future<void> _terminarSolicitud({String from = 'normal'}) async {

    if(from.startsWith('normal')) {
      _revisaFotosDesde = 'terminar';
      bool acc = await _agregarMasPiezas('add');
      if(!acc) { return; }
    }
    _showModalTerminarSol();
  }

  ///
  void _showModalTerminarSol() {

    final provBtn = context.read<BtnSendCotizacionProv>();

    if(pzaCurrent.keysPiezas.isNotEmpty) {
      if(!_isShowModalTerminar) {
        provBtn.activeBtnSend = true;

        _isShowModalTerminar = true;
        isPressTerminar = false;
        showModalBottomSheet<bool>(
          context: context,
          builder: (_) => FrmCotizaModalPzas(
            onEdit: (int keyPza){
              refCotz.keyPiezaEdit = keyPza;
              pzaCurrent.hasFotos = true;
            },
          )
        ).then((bool? isComplete) {
          isComplete = (isComplete == null) ? false : isComplete;
          if(isComplete) {
            _isShowModalTerminar = false;
            Navigator.of(context).pop();
          }

          if(pzaCurrent.keysPiezas.isEmpty) {

            setState(() {});
          }

        });
      }
    }else{
      variosWidgets.message(context: context, msg: 'Aún no hay Autopartes');
    }
  }

  ///
  Future<void> _showModalFotosNoSend(List<String> ftNoSend, {bool onlyCheck = false}) async {

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (_) => WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: FrmCotizaModalFotosIncompletas(
          fotos: ftNoSend,
          onFinish: (Map<String, dynamic> result) async {
            
            Navigator.of(context).pop();
            
            if(result['msg'] == 'ok') {
              if(!onlyCheck) {

                fotosYaEnviadas.addAll(List<String>.from(result['fotos']));
                if(_revisaFotosDesde == 'add') {
                  await _agregarMasPiezas('add');
                  return;
                }else{
                  final from = (pzaCurrent.hasFotos) ? 'normal' : 'fotos';
                  await _terminarSolicitud(from:from);
                  return;
                }
              }else{
                pzaCurrent.hasFotos = false;
              }
            }else{
              // Regresar a las fotos sin guardar pieza
              pzaCurrent.hasFotos = false;
            }
          }
        ),
      )
    );
  }

  ///
  Future<List<String>> _isAllFotosSended() async {

    pzaCurrent.piezaOfOrdenCurrent['fotos'] = [];
    List<Map<String, dynamic>> tmpLst = [];
    List<String> fotosNoEnviadas = [];
    if(kIsWeb) {
      tmpLst = List<Map<String, dynamic>>.from(picktures.imageFileListProcess);
    }else{
      tmpLst = List<Map<String, dynamic>>.from(picktures.imageFileListOks);
    }

    if(tmpLst.isNotEmpty) {

      for (var i = 0; i < tmpLst.length; i++) {

        bool insertar = true;

        final has = tmpLst.where(
          (element) => element['filename'] == tmpLst[i]['filename']
        );
        
        if(has.isNotEmpty) {
          if(has.first['sended']) {
            insertar = false;
            if(!fotosYaEnviadas.contains(has.first['filename'])) {
              fotosYaEnviadas.add(has.first['filename']);
            }
          }
        }else{

          if(tmpLst[i]['from'] == 'server') {
            if(!fotosYaEnviadas.contains(tmpLst[i]['filename'])) {
              fotosYaEnviadas.add(tmpLst[i]['filename']);
              insertar = false;
            }
          }
        }

        if(insertar) {
          if(!fotosNoEnviadas.contains(tmpLst[i]['filename'])) {
            fotosNoEnviadas.add(tmpLst[i]['filename']);
          }
        }
      }
    }

    // Las fotosFromServer ya estan en el servidor por lo tanto ya estan enviadas
    if(picktures.fotosFromServer.isNotEmpty) {
      if(fotosYaEnviadas.length < picktures.maxFotos) {
        for (var i = 0; i < picktures.fotosFromServer.length; i++) {
          if(fotosYaEnviadas.length < picktures.maxFotos) {
            if(!fotosYaEnviadas.contains(picktures.fotosFromServer[i])) {
              fotosYaEnviadas.add(picktures.fotosFromServer[i]);
            }
          }
        }
      }
    }

    tmpLst = [];
    return fotosNoEnviadas;
  }

  ///
  Future<void> _sendPzaToServer() async {

    await for (var keyPza in _repoEm.sendPzaStream(pzaCurrent.pzasToSend)) {
      if(keyPza['key'] != -1) {
        await pzaCurrent.changeDataWith(keyPza['key']!, true);
        setState(() {});
      }
    }
  }

  ///
  Future<void> _cleanScreen() async {

    imageCache.clear();
    pzaCurrent.pzaOfOrdenCurrent = {};
    picktures.idOrden = dsRepo.idRepoMainSelectCurrent;
    pzaCurrent.buildPzaNewOfOrden(idOrd: picktures.idOrden);
    picktures.idPiezaTmp = '${pzaCurrent.piezaOfOrdenCurrent['id']}';
    
    picktures.maxPermitidas = picktures.maxFotos;
    picktures.imageFileList.clear();
    picktures.imageWebList.clear();
    picktures.imageFileListProcess.clear();
    picktures.imageFileListOks.clear();
    picktures.fotosFromServer = [];
    picktures.fotosFromServerDel = [];
    picktures.totalFotosSelected.value = 0;
    
    refCotz.keyPiezaEdit = -1;
    refCotz.isEditWeb = false;
    _revisaFotosDesde = 'add';
    _blockMethod = false;
    _makeFncSend = false;
    _isShowModalTerminar = false;
    fotosYaEnviadas = [];
    if(kIsWeb) {
      context.findAncestorWidgetOfExactType<PiezasAddWebUI>()!.keyPiezaEdit.value = -1;
    }

    setState((){});
  }

  ///
  Future<void> _getSharedFotosFromDevice() async {

    setState(() {
      /// Precionó el BTN para iniciar
      _sharedFotos = 1;
    });

    // Subimos el archivo para ver a que hora lee el QR
    await _repoEm.sendFileForShareFotosFromDevice({
      'orden':picktures.idOrden,
      'idPiezaTmp': picktures.idPiezaTmp,
      'filename': '${picktures.idOrden}-${picktures.idPiezaTmp}',
      'isOpen':false,
      'files' : []
    });
    if(!_repoEm.result['abort']) {
      setState(() {
        // El archivo ya fue subido con exito.
        _sharedFotos = 2;
      });
      _tipoCheck = 'isOpen';
      // Revisamos cada segundo para ver si ya se leyo
      _cronShareFotosFromDevice();
    }
  }

  ///
  Future<void> _registrarPiezaName(Map<String, dynamic> pieza) async {

    bool isNewPiezasRegs = true;
    final pzaR = dsRepo.pzaReg.values.where((element) => element.pieza == pieza['piezaName']);
    if(pzaR.isNotEmpty) {
      pzaR.map((pza) {
        if(pza.lado == pieza['lado']) {
          if(pza.posicion == pieza['posicion']) {
            isNewPiezasRegs = false;
          }
        }
      }).toList();
    }
    
    if(isNewPiezasRegs) { return; }

    PiezasReg piezasReg = PiezasReg();
    piezasReg.pieza    = pieza['piezaName'].trim();
    piezasReg.lado     = pieza['lado'].trim();
    piezasReg.posicion = pieza['posicion'].trim();
    dsRepo.pzaReg.add(piezasReg);
    piezasRegs.add(piezasReg.toJsonToFrm());
  }

  ///
  Future<void> _comprimirAndSendImgs() async {
    if(!_makeFncSend) {
      _makeFncSend = true;
      picktures.comprimirImagen();
    }
  }

  ///
  Future<void> _cronShareFotosFromDevice() async {

    cron = Cron();

    cron.schedule(Schedule.parse('*/1 * * * * *'), () async {

      if(_segundoShared == 0) {
        _segundoShared = (_tipoCheck == 'isOpen') ? 1 : 3;
        _sharedFotosMsg.value = 'Revisando en $_segundoShared';
        await _repoEm.checkFileShareFotos(
          '${picktures.idOrden}-${picktures.idPiezaTmp}',
          _tipoCheck
        );

        if(!_repoEm.result['abort']) {
          
          if(_repoEm.result['msg'] == 'fotos') {

            if(_repoEm.result['body'].containsKey('isFinish')) {
              if(_repoEm.result['body']['isFinish']) {
                _cancelCron = true;
              }
            }
            picktures.fotosFromServer = List<String>.from(_repoEm.result['body']['fotos']);
            picktures.totalFotosSelected.value = picktures.fotosFromServer.length + picktures.imageFileList.length;
            picktures.refreshPage.value = 'refreshPage';
            setState(() {});
          }

          if(_repoEm.result['msg'] == 'isOpen') {
            if(_repoEm.result['body']['result']) {
                // Archivo leido
              _sharedFotos = 3;
              _tipoCheck = 'fotos';
              setState(() {});
            }
          }
        }
        _repoEm.http.cleanResult();
        _repoEm.cleanResult();
      }else{
        _segundoShared--;
        if(_tipoCheck != 'isOpen') {
          _sharedFotosMsg.value = 'Revisando en $_segundoShared';
        }
      }

      if(_cancelCron) {
        _cancelCron = false;
        await _repoEm.removeFileShareFotos(
          '${picktures.idOrden}-${picktures.idPiezaTmp}'
        );
        _sharedFotos = 0;
        _tipoCheck = '';
        setState(() {});
        await cron.close();
      }
    });
  }

}