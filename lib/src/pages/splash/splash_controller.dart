import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'splash_ui.dart';
import '../home/data_shared/ds_repo.dart';
import '../../repository/stt_repository.dart';
import '../../providers/check_login.dart';
import '../../services/fbm_google.dart';
import '../../repository/automovil.dart';

class SplashController extends StatefulWidget {

  const SplashController({Key? key}) : super(key: key);

  @override
  SplashControllerState createState() => SplashControllerState();
}

class SplashControllerState extends State<SplashController> {

  final SttRepository _sttEm = SttRepository();
  final AutomovilRepository _autoEm = AutomovilRepository();
  final Globals globals = getSngOf<Globals>();
  final DsRepo _dsRepo = getSngOf<DsRepo>();
  final FBMGoogle fbm = getSngOf<FBMGoogle>();
  
  late CheckLoginProvider _userProv;
  String taskMsg = 'BIENVENIDO';
  String username = '';

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((_) async => _configurar(null));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SplashUI(context, this);
  
  ///
  Future<void> _configurar(_) async {

    //await _dsRepo.cleanBds();
    _userProv = context.read<CheckLoginProvider>();
    await _dsRepo.initBoxForSplash();
    await _initApp();
  }

  ///
  Future<void> _initApp() async {

    await _userProv.initCheck();
    if(_userProv.preAuth != IsLoged.isAutorized) {
      await _marcas();
      await _status();
    }
    await makeLogin();
  }

  ///
  Future<void> makeLogin() async {

    if(_userProv.isUserAutenticado != _userProv.preAuth) {
      await _servicePush();
      _userProv.setIsUserAutenticado(_userProv.preAuth);
    }
  }

  ///
  Future<void> _marcas() async {

    if(_dsRepo.marcas.values.isEmpty) {
      setState(() { taskMsg = 'Recuperando Marcas'; });
      await _autoEm.getAllMarcasFromServer();
    }
  }
  
  ///
  Future<void> _status() async {

    // globals.checkedStt se marca como verdadero en el loginCheck
    if(globals.checkedStt){ return; }
    setState(() { taskMsg = 'Recuperando Status'; });
    await _sttEm.recoverySttRuta();
  }

  ///
  Future<void> _servicePush() async {

    setState(() {
      taskMsg = 'Inicializando Notificaciones';
    });

    await fbm.init();
    await fbm.recuperandoTokenPush();
    // print(fbm.tokenMsg);
    if(fbm.tokenMsg.isNotEmpty) {

      if(_userProv.user.isEmpty) { return; }
      final us = _userProv.user.getAt(0);

      if(us != null) {

        username = us.username.toUpperCase();
        if(us.tkMsging != fbm.tokenMsg) {
          setState(() { taskMsg = 'Respaldo TokenPush'; });
          us.tkMsging = fbm.tokenMsg;
          us.save();
          await _userProv.enviandoTokenPush(fbm.tokenMsg, globals.idUser);
        }
      }
    }
  }

}