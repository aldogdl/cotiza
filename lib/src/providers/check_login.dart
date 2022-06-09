import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:hive_flutter/hive_flutter.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/boxes_names.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/type_ids.dart';

import '../entity/last_data_in.dart';
import '../repository/user_adm_repository.dart';
import '../entity/user_admin.dart';

enum IsLoged { isAutorized, isAnonimo, isOki, isNone }

class CheckLoginProvider extends ChangeNotifier {

  final Globals _globals = getSngOf<Globals>();
  final UserAdmRepository _userEm = UserAdmRepository();
  late Box<UserAdmin> user;
  Box<LastDataIn>? lastDataIn;

  IsLoged preAuth = IsLoged.isNone;
  IsLoged _isUserAutenticado = IsLoged.isNone;
  IsLoged get isUserAutenticado => _isUserAutenticado;
  void setIsUserAutenticado(IsLoged isAuth) {
    _isUserAutenticado = isAuth;
    notifyListeners();
  }

  ///
  Future<void> initCheck({bool onlyOpen = false}) async {

    if(!Hive.isAdapterRegistered(TypeIds.tiUserAd)) {
      Hive.registerAdapter<UserAdmin>(UserAdminAdapter());
    }

    if(!Hive.isBoxOpen(BoxesNames.userAdminBox)) {
      user = await Hive.openBox<UserAdmin>(BoxesNames.userAdminBox);
    }else{
      user = Hive.box<UserAdmin>(BoxesNames.userAdminBox);
    }
    if(!onlyOpen) {
      await _userAdmin();
    }
  }

  ///
  Future<void> openBoxLastDataIn() async {

    if(!Hive.isAdapterRegistered(TypeIds.tiLdtIn)) {
      Hive.registerAdapter<LastDataIn>(LastDataInAdapter());
    }
    if(!Hive.isBoxOpen(BoxesNames.lastDtaIn)) {
      lastDataIn = await Hive.openBox<LastDataIn>(BoxesNames.lastDtaIn);
    }else{
      lastDataIn = Hive.box<LastDataIn>(BoxesNames.lastDtaIn);
    }
  }

  ///
  Future<void> _userAdmin() async {

    if(_isUserAutenticado == IsLoged.isAutorized) {
      return;
    }

    IsLoged auth = IsLoged.isAnonimo;
    if(user.isNotEmpty) {

      UserAdmin? us = user.getAt(0);
      if(us != null) {
        
        await openBoxLastDataIn();
        if(lastDataIn != null) {
          
          if(lastDataIn!.values.isNotEmpty) {

            if(lastDataIn!.values.first.fecha.isNotEmpty) {

              // Ya ha entrado anteriormente a la app
              final fCurrent = DateTime.now();
              final fLast = DateTime.parse(lastDataIn!.values.first.fecha);
              final diff  = fCurrent.difference(fLast);
              
              if(diff.inHours > 5) {

                auth = IsLoged.isAnonimo;
                // hacemos un login silencioso.
                await _userEm.checkLogin({
                  'username': us.username, 'password': us.password
                });
                if(!_userEm.result['abort']) {
                  us.tkServer = _userEm.result['body'];
                  us.save();
                  auth = IsLoged.isAutorized;
                }
              }else{
                _globals.checkedStt = true;
                _globals.idUser = us.id;
                auth = IsLoged.isAutorized;
              }
            }
          }
        }
      }
    }
    
    if(preAuth != auth) {
      preAuth = auth;
    }

  }

  ///
  Future<String> isTokenCaducado() async {

    await initCheck(onlyOpen: true);
    UserAdmin? us = user.getAt(0);
    await _userEm.isTokenCaducado();
    
    if(_userEm.result['abort']) {

      if(us != null) {
        await _userEm.checkLogin({
          'username': us.username, 'password': us.password
        });
        if(!_userEm.result['abort']) {
          us.tkServer = _userEm.result['body'];
          us.save();
          return us.tkServer;
        }else{
          setIsUserAutenticado(IsLoged.isAnonimo);
          return 'caducado';
        }
      }
    }
    return us!.tkServer;
  }

  ///
  Future<void> enviandoTokenPush(String tokenPush, int idUser) async {

    await _userEm.enviandoTokenPush(tokenPush, idUser);
  }
}