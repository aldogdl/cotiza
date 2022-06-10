import 'dart:async';
import 'package:autoparnet_cotiza/src/pages/home/widgets_home/slices_home/slice_home.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/scroll_config.dart';

import 'widgets_home/frm_cotiza.dart';
import 'widgets_home/mis_procesos.dart';
import 'widgets_home/mis_pendientes.dart';
import 'widgets_home/secc_lst_pendientes.dart';
import 'widgets_home/secc_lst_en_proceso.dart';
import 'data_shared/ds_repo.dart';
import '../respuestas/respuestas_page.dart';
import '../../providers/repos_pendientes_prov.dart';
import '../../providers/repos_proceso_prov.dart';
import '../../providers/pestanias_prov.dart';
import '../../services/fbm_google.dart';
import '../../widgets/varios_widgets.dart';
import '../../widgets/get_auto/auto_controller.dart';
import '../../widgets/get_fotos/singleton/picker_pictures.dart';

class HomeIzqUI extends StatefulWidget {

  final BoxConstraints constraints;
  const HomeIzqUI({
    required this.constraints,
    Key? key
  }) : super(key: key);

  @override
  State<HomeIzqUI> createState() => _HomeIzqUIState();
}

class _HomeIzqUIState extends State<HomeIzqUI> {

  final VariosWidgets variosWidgets = VariosWidgets();
  final globals  = getSngOf<Globals>();
  final refCotiz = getSngOf<RefCotiz>();
  final dsRepo   = getSngOf<DsRepo>();
  final _pickturs= getSngOf<PickerPictures>();
  final fbmGoogle= getSngOf<FBMGoogle>();

  final ValueNotifier<String> _msgNotif = ValueNotifier<String>('Espera un momento por favor');
  final ScrollController _ctrScrollHome = ScrollController();

  String _seccionView = 'home';

  @override
  void dispose() {
    _msgNotif.dispose();
    _ctrScrollHome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(dsRepo.maxW == 0) {
      dsRepo.maxW = globals.getMaxWidht(widget.constraints);
      dsRepo.maxH = globals.getHeight(context);
    }
    return _selectSecciones();
  }

  ///
  Widget _selectSecciones() {

    late Widget seccion;
    switch (_seccionView) {
      case 'home':
        seccion = _home();
        break;
      case 'addAuto':
        seccion = _seccionAddAuto();
        break;
      case 'lst_enproceso':
        seccion = _seccionEnProceso();
        break;
      case 'lst_pendientes':
        seccion = _seccionDePendientes();
        break;
      default:
    }

    return seccion;
  }

  ///
  Widget _home() {

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: ListView(
      controller: _ctrScrollHome,
        shrinkWrap: true,
        children: [
          const SizedBox(height: 15),
          _btnCrearCotizacion(),
          const SizedBox(height: 5),
          MisPendientes(
            onChangeSeccion: (String seccion) => setState(() { _seccionView = seccion; }),
            onTap: (Map<String, dynamic> result) {
              
              dsRepo.fromIdRepo = 'pendientes';
              if(MediaQuery.of(context).size.width <= globals.maxIzq) {
                if(result['acc'] == 'frm') {
                  _openFrmCotizaInMovil();
                }
              }
            },
          ),
          MisProcesos(
            onChangeSeccion: (String seccion) => setState(() { _seccionView = seccion; }),
            onTap: (int keyRepoMain) {
              dsRepo.fromIdRepo = 'proceso';
              if(kIsWeb) {
                context.read<PestaniasProv>().pestaniaSelect = 'Cotizaciones';
              }else{
                _showRespuestasByKeyMain(keyRepoMain);
              }
            }
          ),
          // Hasta que halla algo en el inventario habilitamos esto...
          // OutletsPzas(constraints: widget.constraints)
          const SizedBox(height: 13),
          SlicesHome(constraints: widget.constraints, globals: globals)
        ],
      )
    );
  }

  ///
  Widget _btnCrearCotizacion() {

    double ancho = dsRepo.maxW * 0.7;
    double alto  = 35;

    if(!kIsWeb) {
      // en la APP
      ancho = dsRepo.maxW * 0.8;
      alto  = 40;
    }else{
      if(MediaQuery.of(context).size.width <= globals.maxIzq) {
        ancho = dsRepo.maxW * 0.8;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: ancho,
          height: alto,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ))
              ),
              onPressed: () async {

                bool canAdd = await canAddOfOrden();
                if(canAdd) {
                  setState((){
                    _seccionView = 'addAuto';
                    context.read<PestaniasProv>().pestaniaSelect = 'none';
                  });
                }
              },
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: Text(
                'CREAR NUEVA COTIZACIÓN',
                textScaleFactor: 1,
                style: globals.styleText(14, Colors.white, true),
              )
            )
          ),
        )
      ],
    );
  }
  
  ///
  Widget _seccionAddAuto() {

    return WillPopScope(
      onWillPop: () {
        setState((){ _seccionView = 'home'; });
        return Future.value(false);
      },
      child: AutoController(
        onClose: (_) {
          setState((){ _seccionView = 'home'; });
        },
        isFinish: (keyNew) => _onFinishAddAuto(keyNew),
      ),
    );
  }

  ///
  Widget _seccionDePendientes() {

    return WillPopScope(
      onWillPop: () {
        _seccionView = 'home';
        setState(() {});
        return Future.value(false);
      },
      child: Consumer<ReposPendientesProv>(
        builder: (_, repo, __) {

          return SeccLstPendientes(
            lstKeys: repo.allKeys,
            constraints: widget.constraints,
            onTap: (int keyRepoSelected) async {

              if(keyRepoSelected > -1) {
                if(MediaQuery.of(context).size.width <= globals.maxIzq) {
                  _openFrmCotizaInMovil(callFrom: 'lst_pendientes');
                }
              }else{
                setState(() {
                  _seccionView = 'home';
                });
              }
            }
          );
        },
      ),
    );
  }

  ///
  Widget _seccionEnProceso() {

    return WillPopScope(
      child: Consumer<ReposProcesoProv>(
        builder: (_, provPros, __) {

          return SeccLstEnProceso(
            constraints: widget.constraints,
            lstKeys: provPros.allKeys,
            onTap: (int keyRepoSelected){

              if(keyRepoSelected == -1) {
                setState(() {
                  _seccionView = 'home';
                });
              }else{
                if(!kIsWeb) {
                  _showRespuestasByKeyMain(keyRepoSelected);
                }
              }
            }
          );
        },
      ),
      onWillPop: () {
        setState(() {
          _seccionView = 'home';
        });
        return Future.value(false);
      }
    );
  }

  ///
  void _onFinishAddAuto(dynamic keyNewMain) async {

    bool isOk = true;
    final tam = globals.getDeviceFromMediaQuery(context);
    final p1  = context.read<PestaniasProv>();
    if(keyNewMain.runtimeType == String) {
      if(keyNewMain == 'close') {
        isOk = false;
      }
    }

    if(isOk) {
      dsRepo.idRepoMainSelectCurrent = await context.read<ReposPendientesProv>().addNewRepoMainToScreen(keyNewMain);
      _seccionView = 'home';
      if(tam != 'mediumHandset') {
        p1.pestaniaSelect = 'Cotizar';
      }else{
        _openFrmCotizaInMovil(callFrom: 'home');
      }
    }
    setState(() {});
  }

  ///
  void _openFrmCotizaInMovil({String callFrom = 'home'}) {
    
    final tam = globals.getDeviceFromMediaQuery(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          body: SafeArea(
            child: FrmCotiza(
              constraints: widget.constraints,
              onChangeScreen: (screen) {
                context.read<PestaniasProv>().pestaniaSelect = 'Cotizar';
              },
              onFinish: (idMainSended) async {

                if(context.read<ReposPendientesProv>().allKeys.isEmpty) {
                  if(callFrom != 'home') {
                    _seccionView = 'home';
                  }
                }else{
                  _seccionView = callFrom;
                }

                if(tam == 'mediumHandset') {
                  Navigator.of(context).pop(true);
                }
                setState(() {});
              }
            )
          )
        )
      )
    );
  }

  ///
  void _showRespuestasByKeyMain(keyRepoMain) {

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => RespuestasPage(
          keyRepoMain: keyRepoMain,
          onSendMobil: (_) async {
            final context = ctx;
            final p1 = context.read<ReposProcesoProv>();
            final p2 = context.read<PestaniasProv>();
            final nav = Navigator.of(context);

            dsRepo.getRespuestaPedidoForSend().then((Map<String, dynamic> dataSend ) async {
              refCotiz.showDialogAndSendPedido(context, dataSend).then((bool? res) {
                if(res != null) {
                  if(res) {
                    dsRepo.cambiarRepoFromProcesoToPedidos(context, keyRepoMain);
                    // Revisar si hay un repo en proceso en scene
                    if(p1.inSceneRepo.isNotEmpty) {
                      dsRepo.idRepoMainSelectCurrent = p1.inSceneRepo['idMain'];
                      p2.pestaniaSelect = 'Cotizaciones';
                    }
                    nav.pop();
                  }
                }
              });
            });
          },
        )
      )
    );
  }

  ///
  Future<bool> canAddOfOrden() async {

    if(_pickturs.imageFileListOks.isNotEmpty) {
      bool? acc = await variosWidgets.dialog(
        cntx: context,
        tipo: 'yesOrNot',
        icono: Icons.delete_forever,
        colorIcon: Colors.red,
        titulo: 'REGISTRO DE PIEZA EN PROGRESO',
        textMain: 'Estás en medio de un registro de pieza pendiente.\n '
        'Preciona SÍ, si deseas que el registro de la pieza actual\n '
        'sea eliminado antes de CREAR NUEVA COTIZACIÓN.',
        textSec: 'Presiona NO, para continuar con el registro de la pieza actual.'
      );
      return acc ?? false;
    }else{
      return true;
    }
  }
}
