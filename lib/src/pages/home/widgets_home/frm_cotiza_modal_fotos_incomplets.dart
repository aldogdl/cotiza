import 'dart:io';

import 'package:autoparnet_cotiza/src/widgets/sending/circle_progress.dart';
import 'package:autoparnet_cotiza/src/widgets/sending/circle_progress_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cron/cron.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import '../../../widgets/get_fotos/singleton/picker_pictures.dart';

class FrmCotizaModalFotosIncompletas extends StatefulWidget {

  final List<String> fotos;
  final ValueChanged<Map<String, dynamic>> onFinish;
  const FrmCotizaModalFotosIncompletas({
    Key? key,
    required this.fotos,
    required this.onFinish
  }) : super(key: key);

  @override
  State<FrmCotizaModalFotosIncompletas> createState() => _FrmCotizaModalFotosIncompletasState();
}

class _FrmCotizaModalFotosIncompletasState extends State<FrmCotizaModalFotosIncompletas> {

  final _cron = Cron();
  final Globals globals = getSngOf<Globals>();
  final PickerPictures picktures = getSngOf<PickerPictures>();
  final ScrollController _ctrScroll = ScrollController();

  String pathSended = '';
  List<String> fotosSended = [];
  List<String> fotosNoSended = [];
  int indexSearch = -1;
  int veces = 0;

  @override
  void initState() {
    
    for (var i = 0; i < widget.fotos.length; i++) {

      List<Map<String, dynamic>> has = picktures.imageFileListProcess.where(
        (element) => element['filename'] == widget.fotos[i]
      ).toList();

      if(kIsWeb) {

        if(has.isNotEmpty && !has.first['sended']) {
          fotosNoSended.add(widget.fotos[i]);
        }
      }else{

        if(has.isEmpty) {
          fotosNoSended.add(widget.fotos[i]);
        }
      }
    }

    if(fotosNoSended.isNotEmpty) {
      indexSearch = 0;
      checando();
    }
    super.initState();
  }

  @override
  void dispose() {
    _ctrScroll.dispose();
    _cron.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget child = const SizedBox();

    if(pathSended.isEmpty) {
      child = Center(
        child: Text(
          'En Proceso...\nEspera un momento, por favor',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: globals.styleText(18, Colors.orange, true)
        ),
      );
    }

    if(pathSended.startsWith('ok')) {
      Future.delayed(const Duration(milliseconds: 150), () {
        widget.onFinish({'msg':'ok', 'fotos':fotosSended});
      });
    }

    if(pathSended.contains('/')) {
      if(kIsWeb) {
        child = Image.network(pathSended, fit: BoxFit.contain);
      }else{
        child = Image.file(File(pathSended), fit: BoxFit.contain );
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.35,
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white.withOpacity(0.1),
            child: Text(
              'Completando ORDEN. Revisando Datos',
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: globals.styleText(18, Colors.blue, true),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: fotosNoSended.map((f) {

              return Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  height: 10, width: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (fotosSended.contains(f))
                    ? const Color.fromARGB(255, 121, 120, 119)
                    : (pathSended.startsWith('error'))
                      ? const Color.fromARGB(255, 250, 68, 55)
                      : const Color.fromARGB(255, 33, 150, 243),
                  ),
                  child: const SizedBox(),
                ),
              );

            }).toList(),
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.width * 0.35,
                child: CircleProgress(
                  valores: CircleProgressEntity(
                    progreso: '${fotosNoSended.length}',
                    totalData: '${fotosSended.length}',
                    elemento: 'Imágenes'
                  ),
                  isBasic: true,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  height: MediaQuery.of(context).size.height * 0.20,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.all(5),
                  child: child
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  ///
  Future<void> checando() async {
    
    _cron.schedule(Schedule.parse('*/1 * * * * *'), () {

      var has = picktures.imageFileListProcess.where(
        (element) => element['filename'] == fotosNoSended[indexSearch]
      ).toList();

      if(has.isNotEmpty) {
        pathSended = has.first['path'];
        fotosSended.add(fotosNoSended[indexSearch]);
        indexSearch++;
        setState(() {});
      }
      if(veces == 24 && fotosNoSended.length != fotosSended.length) {
        pathSended = 'error';
        _cron.close();
        setState(() {});
      }

      if(fotosNoSended.length == fotosSended.length) {
        pathSended = 'ok';
      }
      veces++;
    });
  }

}