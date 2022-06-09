import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/scroll_config.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';

import 'singleton/picker_pictures.dart';
import 'widgets/container_buid_foto.dart';
import 'widgets/title_and_actions.dart';
import '../varios_widgets.dart';
import '../../services/get_uris.dart';

class GetFotosWeb extends StatefulWidget {

  final BoxConstraints constraints;
  final ValueChanged<Map<String, dynamic>> onDelete;
  final int cantMax;
  final int idOrden;
  const GetFotosWeb({
    required this.constraints,
    required this.onDelete,
    required this.cantMax,
    required this.idOrden,
    Key? key
  }) : super(key: key);

  @override
  State<GetFotosWeb> createState() => _GetFotosWebState();
}

class _GetFotosWebState extends State<GetFotosWeb> {

  final VariosWidgets variosWidgets = VariosWidgets();
  final Globals globals = getSngOf<Globals>();
  final PickerPictures picktures = getSngOf<PickerPictures>();
  final ScrollController _ctrScroll = ScrollController();
  final String msgDropFinal = 'o puedes Arrastra y Sueltar aquí tus Imágenes';

  bool highlighted = false;
  String msgDrop = 'o puedes Arrastra y Sueltar aquí tus Imágenes';
  double moveScroll = 0;
  String idTmpImgQr = '0';
  late DropzoneViewController controller;

  @override
  void initState() {
    idTmpImgQr = '${widget.idOrden}-0-${picktures.idPiezaTmp}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 130
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: picktures.totalFotosSelected,
            builder: (_, int tot, __) {

              return TitleAndActions(
                totalMax: widget.cantMax,
                totCurrent: tot,
                theme: 'dark',
                onTap: (String tipo) async {
                  _putImagesFromClick();
                }
              );
            }
          ),
          Expanded(
            child: ContainerBuildFoto(
              constraints: widget.constraints,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: (picktures.totalFotosSelected.value == 0)
                    ? _zonaDragAndDrop()
                    : _buildListFotos(),
                  )
                ],
              )
            )
          )
        ]
      )
    );
  }

  ///
  Widget _buildListFotos() {

    picktures.buildLstDeFotosOk(prefix: 'nc-');
    
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent) {
          
          if(event.scrollDelta.dy == -100) {
            // Arriba scroll mouse
            moveScroll = 0;
          }else{
            // Abajo scroll mouse
            moveScroll = 300;
          }
          _ctrScroll.animateTo(
            moveScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut
          );
        }
      },
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: ListView(
          controller: _ctrScroll,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: picktures.imageFileListOks.map<Widget>((foto) => _viewFoto(foto)).toList()
        ),
      ),
    );

  }

  ///
  Widget _viewFoto(Map<String, dynamic> foto) {

    double alto = widget.constraints.maxHeight * 0.25;
    late Widget child;
    if(foto['from'] == 'server') {
      child = Image.network(
        GetUris.getUriFotoPzaBeforeCot(foto['filename']),
        fit: BoxFit.cover,
      );
    }else{
      child = Image.network(
        foto['path'],
        fit: BoxFit.cover,
      );
    }

    return SizedBox(
      width: ((1024*alto)/768) * 0.6,
      height: widget.constraints.maxHeight * 0.30,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: 1024/768,
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1
                  )
                ),
                child: child,
              )
            ),
          ),
          Positioned(
            top: 5, left: 5,
            child: IconButton(
              onPressed: () async {
                widget.onDelete(foto);
                _refresScreen();
              },
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15,
                child: Icon(
                  Icons.delete, color: (foto['from'] == 'server') ? Colors.orange : Colors.red
                )
              )
            )
          ),
        ],
      ),
    );
  }

  ///
  Widget _zonaDragAndDrop() {

    return Container(
      width: widget.constraints.maxWidth,
      margin: const EdgeInsets.all(10),
      color: (highlighted) ? Colors.grey[100] : Colors.white,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DropzoneView(
              onCreated: (ctr) => controller = ctr,
              onDrop: onDropFiles,
              cursor: CursorType.grab,
              mime: const ['image/png', 'image/jpeg'],
              onHover: () {
                setState(() {
                  msgDrop = 'Suelta las imagenes ahora :)';
                  highlighted = true;
                });
              },
              onLeave: () {
                setState(() {
                  msgDrop = msgDropFinal;
                  highlighted = false;
                });
              }
            )
          ),
          InkWell(
            onTap: () async => _putImagesFromClick(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.snippet_folder_rounded,
                        color: Color.fromARGB(255, 194, 194, 194),
                        size: 35
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Click para abrir el Explorador de Archivos',
                            textScaleFactor: 1,
                            textAlign: TextAlign.center,
                            style: globals.styleText(13, Colors.blue, false, sw: 1.1),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            msgDrop,
                            textScaleFactor: 1,
                            textAlign: TextAlign.center,
                            style: globals.styleText(13, Colors.grey, false),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            )
          ),
        ],
      )
    );
  }

  ///
  Future<void> onDropFiles(dynamic event) async {

    XFile file = XFile.fromData(
      await controller.getFileData(event),
      length: await controller.getFileSize(event),
      mimeType: await controller.getFileMIME(event),
      name: await controller.getFilename(event),
      path: await controller.createFileUrl(event),
    );

    if(picktures.imageFileList.length < widget.cantMax) {
      picktures.imageFileList.add(file);
    }
    _refresScreen();
  }

  ///
  Future<void> _putImagesFromClick() async {

    await picktures.action('galery');
    if(picktures.imageFileList.isNotEmpty) {
      _refresScreen();
    }
  }

  ///
  void _refresScreen() {

    int fotosCurrent = 0;
    if(picktures.imageFileListOks.isNotEmpty) {
      fotosCurrent = picktures.imageFileListOks.length;
    }
    if(picktures.imageFileList.isNotEmpty) {

      int totf = picktures.imageFileList.length;
      if(picktures.imageFileListOks.isNotEmpty) {
        totf = 0;
        for (var f = 0; f < picktures.imageFileList.length; f++) {
          final has = picktures.imageFileListOks.where((element) => element['path'] == picktures.imageFileList[f].path);
          if(has.isEmpty) {
            totf++;
          }
        }
      }
      fotosCurrent = fotosCurrent + totf;
    }

    msgDrop = msgDropFinal;
    highlighted = false;
    idTmpImgQr = '${widget.idOrden}-$fotosCurrent-${picktures.idPiezaTmp}';
    picktures.totalFotosSelected.value = fotosCurrent;
    setState(() {});
  }

}