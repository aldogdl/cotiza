import 'package:autoparnet_cotiza/src/services/get_uris.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';
import 'package:autoparnet_cotiza/vars/scroll_config.dart';

import 'circle_progress_entity.dart';
import 'send_data_ui.dart';
import '../varios_widgets.dart';
import '../../entity/orden.dart';
import '../../entity/orden_piezas.dart';
import '../../pages/home/data_shared/ds_repo.dart';
import '../get_fotos/widgets/container_buid_foto.dart';
import '../get_fotos/singleton/picker_pictures.dart';

class SendingDataPiezas extends StatefulWidget {

  final ValueChanged<int> onSended;
  final BoxConstraints constraints;
  const SendingDataPiezas({
    required this.onSended,
    required this.constraints,
    Key? key
  }) : super(key: key);

  @override
  State<SendingDataPiezas> createState() => _SendingDataPiezasState();
}

class _SendingDataPiezasState extends State<SendingDataPiezas> {

  final globals = getSngOf<Globals>();
  final refCotz = getSngOf<RefCotiz>();
  final dsRepo  = getSngOf<DsRepo>();

  final VariosWidgets variosWidgets = VariosWidgets();
  final PickerPictures picktures = getSngOf<PickerPictures>();
  final ScrollController _ctrScroll = ScrollController();
  final ValueNotifier<int> keyPizaCurrent = ValueNotifier<int>(-1);

  late CircleProgressEntity valsProgress;
 
  String tipoConection = 'none';
  String txtMsgChangeKeyPzaSend = 'Configurando Envío';
  String msgMainSending = '...';
  String pathFotoSend = '0';
  int totalDelProgreso = 0;
  List<int> keyForSend = [];

  @override
  void initState() {

    valsProgress = CircleProgressEntity(
      taskMain: 'ENVIANDO',
      elemento: 'COTIZACIÓN',
      progreso: '0',
      totalData: 'Pzs.'
    );
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }

  @override
  void dispose() {
    PaintingBinding.instance.imageCache.clear();
    imageCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SendDataUi(
      onFinish: (result){},
      onChangeConnection: (cnx) {
        setState(() {
          tipoConection = cnx;
        });
      },
      valoresProgress: valsProgress,
      children: (tipoConection == 'none') ? _awaitCnx(-1, 'ESPERANDO...') : _makeProcess(),
    );
  }

  ///
  List<Widget> _awaitCnx(int keyPza, String txt) {

    return [
      Text(txt, style: globals.styleText(17, Colors.white, false) ),
    ];
  }

  ///
  List<Widget> _makeProcess() {

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          msgMainSending,
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: globals.styleText(15, Colors.green, false)
        )
      ),
      ValueListenableBuilder(
        valueListenable: keyPizaCurrent,
        builder: (_, int keyPza, __) {

          if(keyPza == -1){ return const SizedBox(); }

          OrdenPiezas? rpza = dsRepo.ordenPzas.get(keyPza);
          if(rpza == null){ return const SizedBox(); }

          return _awaitCnx(keyPza, txtMsgChangeKeyPzaSend)[0];
        }
      ),
      const SizedBox(height: 10),
      ValueListenableBuilder(
        valueListenable: picktures.refreshPage,
        builder: (_, String refresh, __) {

          if(refresh == 'refreshPage') {
            Future.delayed(const Duration(milliseconds: 100), (){
              setState((){});
              picktures.refreshPage.value = 'none';
            });
          }

          return ContainerBuildFoto(
            constraints: widget.constraints,
            child: _containerFotos()
          );
        }
      )
    ];
  }

  ///
  Widget _containerFotos() {

    return SizedBox(
      height: 150,
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: ListView.builder(
          key: UniqueKey(),
          controller: _ctrScroll,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          scrollDirection: Axis.horizontal,
          itemCount: picktures.fotosFromServer.length,
          itemBuilder: (_, index) => _containerImg(index)
        ),
      )
    );
  }

  ///
  Widget _containerImg(int index) {

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10), 
      ),
      margin: const EdgeInsets.only(right: 10),
      child: AspectRatio(
        aspectRatio: 1024/768,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  GetUris.getUriFotoPzaBeforeCot(picktures.fotosFromServer[index]),
                  fit: BoxFit.cover
                )
              ),
            ],
          )
        ),
      )
    );
  }

  ///
  Future<void> _initWidget(_) async {

    Map<String, dynamic> msgErrs = {
      'titulo': 'Solicitud no Recuperada',
      'textMain': 'Lo sentimos ocurrio un Error inesperado, por favor inténtalo nuevamente.',
      'textSec': 'No pudimos recuperar desde la Base de Datos el registro de esta Cotización.'
    };

    bool alert = true;
    await dsRepo.openBoxOrden();
    await dsRepo.openBoxOrdenPzas();
    
    Iterable<Orden>? existMain = dsRepo.orden.values.where((main) => main.id == dsRepo.idRepoMainSelectCurrent);

    if(existMain.isNotEmpty) {

      if(existMain.first.id == dsRepo.idRepoMainSelectCurrent) {

        msgErrs['titulo']  = 'Sin Piezas para enviar';
        msgErrs['textMain']= 'No pudimos detectar piezas para el auto';
        msgErrs['textSec'] = 'Por favor, ingresa Autopartes para poder enviar una cotización completa.';

        picktures.idOrden = existMain.first.id;
        if(dsRepo.ordenPzas.values.isNotEmpty) {

          dsRepo.ordenPzas.values.map((p){
            if(p.orden == existMain.first.id) {
              keyForSend.add(p.key);
            }
          }).toList();

          if(keyForSend.isNotEmpty) {
            valsProgress.totalData = '${keyForSend.length} Pza.';
            totalDelProgreso = keyForSend.length;
            alert = false;
            _initProcessSend();
          }
        }
      }
    }

    if(alert) {

      if(!kIsWeb) {
        await variosWidgets.dialog(
          cntx: context,
          tipo: 'entendido',
          icono: Icons.data_saver_off,
          colorIcon: Colors.orange,
          titulo: msgErrs['titulo'],
          textMain: msgErrs['textMain'],
          textSec: msgErrs['textSec'],
        );
      }
      if(!mounted) return;
      Navigator.of(context).pop();
    }
  }

  ///
  Future<void> _initProcessSend() async {

    if(keyForSend.isEmpty) {
      // En el momento que no halla nada para enviar, mandamos la notificacion al SCP
      await _finDelProceso();
      return;
    }

    valsProgress.progreso = '${totalDelProgreso - (keyForSend.length - 1)}';
    keyPizaCurrent.value = keyForSend.first;
    msgMainSending = 'Número de Orden ${valsProgress.progreso}';
    _sendDataPieza();
  }

  ///
  Future<void> _sendDataPieza() async {

    OrdenPiezas? pza = dsRepo.ordenPzas.get(keyPizaCurrent.value);
    if(pza != null) {
      if(pza.fotos.isNotEmpty) {
        picktures.fotosFromServer = pza.fotos;
      }
      picktures.refreshPage.value = 'refreshPage';
      await Future.delayed(const Duration(milliseconds: 200));

      await Future.delayed(const Duration(milliseconds: 2000));
      keyForSend.removeAt(0);
      _initProcessSend();
    }else{

    }
    
    // if(!_repoEm.result['abort']) {
    //   idPiezaSaved = _repoEm.result['body']['id'];
    //   txtMsgChangeKeyPzaSend = 'No. de Orden: $idPiezaSaved';
    //   msgMainSending = 'Enviando Fotografías';
    //   pza!.id = idPiezaSaved;
    //   pza.statusId  = _repoEm.result['body']['status_id'];
    //   pza.statusNom = _repoEm.result['body']['status_nom'];
    //   pza.save();
    //   int key = await dsRepo.getKeyRepoMainById(idOrden);
    //   RepoMain? repoMain = dsRepo.getRepoMainByKey(key);
    //   if(repoMain != null) {
    //     if(repoMain.statusId != pza.statusId) {
    //       repoMain.statusId = pza.statusId;
    //       repoMain.statusNom = pza.statusNom;
    //       repoMain.save();
    //     }
    //   }
    //   _repoEm.cleanResult();
    //   _initProcessSend();
    // }
  }

  ///
  Future<void> _finDelProceso() async {

    // String fechr = DateTime.now().toIso8601String();
    // Iterable<RepoPizas> pzas = dsRepo.repoPzas.values.where((p) => p.repo == idOrden);

    // context.read<BtnSendCotizacionProv>().activeBtnSend = false;
    // refCotz.isEditWeb = false;
    // refCotz.keyPiezaEdit = -1;

    // // Eliminarla de pendientes y colocar la siguiente, en caso de existir
    
    // // Colocarla en proceso como principal.
    // if(keyRepoSended > -1) {
    //   context.read<ReposProcesoProv>().addToKeys = keyRepoSended;
    //   context.read<ReposProcesoProv>().setInSceneByKeyRepo(-1);
    //   widget.onSended(idOrden);
    // }
    Navigator.of(context).pop();
    return;
  }
}