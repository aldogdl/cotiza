import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'my_camera.dart';
import 'singleton/picker_pictures.dart';
import 'widgets/container_buid_foto.dart';
import 'widgets/ico_foto_from.dart';
import 'widgets/title_and_actions.dart';
import '../varios_widgets.dart';
import '../../services/get_uris.dart';

class GetFotosMovil extends StatefulWidget {

  final BoxConstraints constraints;
  final int cantMax;
  final int idOrden;
  final String theme;
  final ValueChanged<Map<String, dynamic>> onDelete;
  const GetFotosMovil({
    required this.constraints,
    required this.cantMax,
    required this.idOrden,
    required this.onDelete,
    this.theme = 'light',
    Key? key
  }) : super(key: key);
  @override
  State<GetFotosMovil> createState() => _GetFotosMovilState();
}

class _GetFotosMovilState extends State<GetFotosMovil> {

  final VariosWidgets variosWidgets = VariosWidgets();
  final Globals globals = getSngOf<Globals>();
  final PickerPictures picktures = getSngOf<PickerPictures>();
  final ScrollController _ctrFotos = ScrollController();
  
  @override
  void dispose() {
    _ctrFotos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    bool fotosIsEmpty = false;
    if(picktures.fotosFromServer.isEmpty) {
      if(picktures.imageFileList.isEmpty) {
        fotosIsEmpty = true;
      }
    }

    return ValueListenableBuilder(
      valueListenable: picktures.refreshPage,
      builder: (_, String refresh, __) {

        if(refresh == 'refreshPage') {
          Future.delayed(const Duration(milliseconds: 100), (){
            picktures.refreshPage.value = 'none';
            setState((){});
          });
        }

        int cantCurrent = picktures.imageFileList.length;
        if(picktures.fotosFromServer.isNotEmpty) {
          cantCurrent = cantCurrent + picktures.fotosFromServer.length;
        }

        return Column(
          children: [
            TitleAndActions(
              totalMax: widget.cantMax,
              totCurrent: cantCurrent,
              theme: widget.theme,
              onTap: (String tipo) async {
                if(tipo == 'camera') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => _showCamera())
                  );
                }else{
                  picktures.action(tipo);
                }
              }
            ),
            const SizedBox(height: 10),
            ContainerBuildFoto(
              callFrom: 'mobil',
              constraints: widget.constraints,
              child: (fotosIsEmpty)
              ? _containerFotosEmpty()
              : _containerFotos()
            ),
          ]
        );
      }
    );
  }

  ///
  Widget _containerFotosEmpty() {

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if(globals.isMobileDevice)
            ...[
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => _showCamera())
                  );
                },
                child: IcoFotoFrom(
                  icono: Icons.camera_enhance_rounded,
                  label: 'CÁMARA',
                  colorLabel: (widget.theme == 'light') ? Colors.grey[200]! : Colors.black
                )
              ),
              const SizedBox(width: 30),
            ],
          TextButton(
            onPressed: () => picktures.action('galeria'),
            child: IcoFotoFrom(
              icono: Icons.snippet_folder_rounded,
              label: 'GALERÍA',
              colorLabel: (widget.theme == 'light') ? Colors.grey[200]! : Colors.black
            )
          ),
        ],
      )
    );
  }

  ///
  Widget _containerFotos() {

    int cantFotos = picktures.imageFileList.length + picktures.fotosFromServer.length;
    List<Map<String, dynamic>> data = [];
    for (var i = 0; i < picktures.imageFileList.length; i++) {
      data.add({'from':'xfile', 'path': picktures.imageFileList[i].path});
    }
    for (var i = 0; i < picktures.fotosFromServer.length; i++) {
      data.add({'from':'server', 'filename': picktures.fotosFromServer[i]});
    }

    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        controller: _ctrFotos,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        addAutomaticKeepAlives: false,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        itemCount: cantFotos,
        itemBuilder: (_, int index) => _containerImg(index, data: data[index])
      )
    );
  }

  ///
  Widget _containerImg(int index, {Map<String, dynamic>? data}) {

    late Widget child;

    switch (index) {
      case -1:
        child = const Icon(Icons.no_photography);
        break;
      case -2:
        child = Image.file(
          File(picktures.pictureTmp!.path),
          fit: BoxFit.cover,
        );
        break;
      default:

        if(data!['from'] == 'xfile'){
          child = Image.file(
            File(data['path']),
            fit: BoxFit.cover,
          );
        }

        if(data['from'] == 'server') {
          child = FadeInImage(
            placeholder: const AssetImage('assets/images/cogs.gif'),
            image: NetworkImage(GetUris.getUriFotoPzaBeforeCot(data['filename'])),
            fit: BoxFit.cover,
          );
        }
    }
    
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10), 
      ),
      margin: const EdgeInsets.only(right: 10),
      child: AspectRatio(
        aspectRatio: 1024/768,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: child
            ),
            Positioned(
              top: 4, left: 4,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.delete,
                    color: (data!['from'] == 'server')
                      ? Colors.orange : Colors.red
                  ),
                  onPressed: () {
                    widget.onDelete(data);
                    setState((){});
                  }
                )
              )
            )
          ],
        )
      )
    );
  }

  ///
  Widget _showCamera() {

    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () {
          picktures.refreshPage.value = 'refreshPage';
          return Future.value(true);
        },
        child: MyCamera(
          cameraDescription: globals.firstCamera!,
          cantPermitiva: picktures.maxFotos,
          fotosCurrent: picktures.imageFileList,
          onFinish: (List<XFile> fotos) {
            picktures.refreshPage.value = 'refreshPage';
            picktures.imageFileList = fotos;
            setState((){});
          },
        )
      ),
    );
  }

  ///
  void _onPermissionsResult(bool? granted) {

    if(granted != null) {
        
      if (!granted) {
        AlertDialog alert = AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'Parece que no haz\'t autorizado algunos permisos. Comprueba tu configuración e inténtalo de nuevo.',
            textScaleFactor: 1
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );

        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      } else {
        setState(() {});
      }
    }
  }
  
}