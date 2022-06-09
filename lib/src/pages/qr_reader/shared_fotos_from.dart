import 'dart:io';
import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import '../home/widgets_home/painter_bg.dart';
import '../../repository/repos_repository.dart';
import '../../widgets/get_fotos/singleton/picker_pictures.dart';
import '../../widgets/varios_widgets.dart';
import '../../widgets/get_fotos/get_fotos_movil.dart';
import '../../widgets/sending/circle_progress_entity.dart';
import '../../widgets/sending/send_data_ui.dart';

class SharedFotosFrom extends StatefulWidget {

  final String codeQr;
  final BoxConstraints constraints;
  final ValueChanged<void> onFinish;
  const SharedFotosFrom({
    required this.constraints,
    required this.codeQr,
    required this.onFinish,
    Key? key
  }) : super(key: key);

  @override
  State<SharedFotosFrom> createState() => _SharedFotosFromState();
}

class _SharedFotosFromState extends State<SharedFotosFrom> {

  final Globals globals = getSngOf<Globals>();
  final PickerPictures picktures = getSngOf<PickerPictures>();
  final VariosWidgets variosWidgets = VariosWidgets();
  final ScrollController _ctrScroll = ScrollController();
  final RepoRepository _repoEm = RepoRepository();

  List<String> codePartes = [];
  int restan = 0;
  String pathFotoSend = '0';
  String typeSend = 'sol';

  int totalDelProgreso = 0;
  int indexFotoSended = -1;
  bool goProcess = false;
  bool showBtnErr= false;
  late CircleProgressEntity valuesCircle;
  late StateSetter stateDialog;

  @override
  void initState() {
    
    if(widget.codeQr.startsWith('ctz')){
      List<String> partes = widget.codeQr.split('::');
      codePartes = partes[1].split('-');
      typeSend = 'ctz';
    }else{
      codePartes = widget.codeQr.split('-');
    }

    if(codePartes.isNotEmpty) {
      restan = int.parse(codePartes[1]);
      picktures.maxPermitidas = restan;
    }
    picktures.fotosFromServer = [];
    picktures.fotosFromServerDel = [];
    picktures.imageFileList.clear();
    picktures.imageFileListOks.clear();
    picktures.imageFileListProcess.clear();
    imageCache.clear();
    WidgetsBinding.instance.addPostFrameCallback(_openFileShareToServer);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COMPARTIENDO IMAGENES',
          textScaleFactor: 1,
          style: globals.styleText(17, Colors.white, true)
        ),
      ),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.topCenter,
          children: <Widget>[
            CustomPaint(
              painter: PainterBG(),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Text(
                    'Podrás subir hasta $restan imágenes para la ${ (typeSend == 'sol') ? 'Orden' : 'Cotización' } indicada',
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: globals.styleText(17, Colors.grey[300]!, false),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    codePartes[0],
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: globals.styleText(35, Colors.blue, true),
                  ),
                  Text(
                    'No. de Orden',
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: globals.styleText(11, Colors.grey, true),
                  ),
                  const Center(
                    child: Icon(Icons.upload, size: 100, color: Colors.orange),
                  ),
                  Text(
                    'Selecciona desde dónde deseas recuperar Fotografías',
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: globals.styleText(20, Colors.blue, false),
                  ),
                  const SizedBox(height: 20),
                  GetFotosMovil(
                    cantMax: picktures.maxPermitidas,
                    constraints: widget.constraints,
                    idOrden: int.parse(codePartes.first),
                    theme: 'light',
                    onDelete: (_){},
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  ElevatedButton(
                    onPressed: () => (picktures.imageFileList.isNotEmpty)
                      ? _openPageToSendFotos(): _msgScafold(),
                    child: Text(
                      'Compartir Fotos ahora',
                      textScaleFactor: 1,
                      style: globals.styleText(16, Colors.black, true)
                    )
                  )
                ],
              ),
            ),
          ]
        ),
      )
    );
  }

  ///
  void _openPageToSendFotos() {

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => StatefulBuilder(
          builder: (_, StateSetter stateSelf) {

            valuesCircle = CircleProgressEntity(
              taskMain: 'COMPARTIENDO',
              elemento: 'IMÁGENES',
              totalData: '${picktures.imageFileList.length}',
              progreso: '$totalDelProgreso'
            );
            
            stateDialog = stateSelf;

            return WillPopScope(
              onWillPop: () => Future.value(true),
              child: SendDataUi(
                onChangeConnection: (cnx) {
                  stateSelf((){});
                  _initProcess();
                },
                valoresProgress: valuesCircle,
                onFinish: (result) {},
                children: [
                  ValueListenableBuilder<Map<String, dynamic>>(
                    valueListenable: picktures.msgExport,
                    builder: (_, val, __) {
                      
                      if(val.containsKey('num_foto')) {
                        if(val['num_foto'] != totalDelProgreso) {
                          totalDelProgreso = val['num_foto'];
                          Future.delayed(const Duration(milliseconds: 300), (){
                            if(mounted) {
                              stateDialog((){});
                              setState(() {});
                            }
                          });
                        }
                      }

                      if(val['msg'] == 'Listo') {

                        picktures.imageFileList.clear();
                        picktures.imageFileListProcess.clear();
                        picktures.imageFileListOks.clear();
                        imageCache.clear();
                        picktures.msgExport.value = {'msg':'Notificando', 'num_foto':0};
                        _notificarFin();
                      }

                      return Text(
                        val['msg'],
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: globals.styleText(15, Colors.amber, true)
                      );
                    }
                  ),
                  const SizedBox(height: 10),
                  if(showBtnErr)
                    _showError(),

                  _containerFotos(),
                ],
              ),
            );
          },
        )
      )
    );
  }

  ///
  Widget _showError() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red)
          ),
          child: Text(
            'SALIR',
            textScaleFactor: 1,
            style: globals.styleText(15, Colors.white, true),
          )
        ),
        ElevatedButton(
          onPressed: () => picktures.comprimirImagen(),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.orange)
          ),
          child: Text(
            'ERROR, INTENTAR NUEVAMENTE',
            textScaleFactor: 1,
            style: globals.styleText(15, Colors.white, true),
          )
        )
      ]
    );
  }

  ///
  Widget _containerFotos() {

    if(picktures.imageFileListOks.isNotEmpty) {
      int indexWhere = picktures.imageFileListOks.indexWhere((element) => !element['sended']);
      pathFotoSend = picktures.imageFileListOks[indexWhere]['path'];
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      child: ListView.builder(
        key: UniqueKey(),
        controller: _ctrScroll,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: picktures.imageFileListOks.length,
        itemBuilder: (_, index) {

          if(picktures.imageFileListOks.isNotEmpty) {
            if(!picktures.imageFileListOks[index]['sended']) {
              return _containerImg(picktures.imageFileListOks[index]['path']);
            }
          }
          return const SizedBox();
        }
      )
    );
  }

  ///
  Widget _containerImg(String path) {

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
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                )
              ),
              if(pathFotoSend != path)
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8)
                    ),
                  )
                )
            ],
          )
        ),
      )
    );
  }

  /// Marcar como abirto el archivo en el servidor para compartir
  Future<void> _openFileShareToServer(_) async {

    picktures.tokenServer = await _repoEm.getTokenServer();
    await _repoEm.openFileShareFotosFromDevice('${codePartes.first}-${codePartes.last}');
  }
  
  /// Marcar como fin el archivo de compartir para que sepa la web que ya no habrá mas
  /// imagenes que subir y poder borrar el archivo.
  Future<void> _notificarFin() async {

    picktures.tokenServer = await _repoEm.getTokenServer();
    await _repoEm.notificarFinSharedImgs('${codePartes.first}-${codePartes.last}');
    //Navigator.of(context).pushNamedAndRemoveUntil(RutasConfig.bienvenido (route) => false);
  }

  ///
  void _initProcess() async {

    totalDelProgreso = 0;
    if(picktures.imageFileList.isNotEmpty) {
      
      pathFotoSend = picktures.imageFileList.first.path;
      totalDelProgreso = totalDelProgreso +1;
      picktures.msgExport.value = {'msg':'Iniciando...', 'num_foto':totalDelProgreso};
      picktures.idOrden = int.parse(codePartes.first);
      picktures.idPiezaTmp = codePartes.last;
      stateDialog((){});
      if(picktures.tokenServer == '0') {
        picktures.tokenServer = await _repoEm.getTokenServer();
      }
      await picktures.comprimirImagen(prefix: 'share-');

    }else{
      Navigator.of(context).pop();
      widget.onFinish(null);
    }

  }

  ///
  void _msgScafold() {

    variosWidgets.message(
      context: context,
      msg: 'Sin Fotogrfías para enviar',
      bg: Colors.red, fg: Colors.white
    );
  }

}