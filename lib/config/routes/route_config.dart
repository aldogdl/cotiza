import 'package:flutter/material.dart' show BuildContext;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../src/pages/base.dart';
import '../../src/pages/home/home_ui.dart';
import '../../src/pages/splash/splash_controller.dart';
import '../../src/pages/user_reg/user_login_ui.dart';
import '../../src/providers/check_login.dart';

class RutasConfig {

  static String base = '/';
  static String splash = '/splash';
  static String login = '/login';
  static String bienvenido = '/bienvenido';

  static GoRouter rutas(BuildContext context){

    final cus = context.read<CheckLoginProvider>();

    return GoRouter(
      initialLocation: RutasConfig.splash,
      routes: <GoRoute>[
        GoRoute(
          path: base,
          name: 'base',
          builder: (BuildContext context, GoRouterState state) => const Base(),
        ),
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (BuildContext context, GoRouterState state) => const SplashController(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (BuildContext context, GoRouterState state) => const UserLoginUi(),
        ),
        GoRoute(
          path: bienvenido,
          name: 'bienvenido',
          builder: (BuildContext context, GoRouterState state) => const MyHomePage(),
        ),
      ],
      redirect: (state) {

        String goPage = state.subloc;
        if (cus.isUserAutenticado == IsLoged.isAutorized) {
          if(goPage == splash) {
            goPage = base;
          }else{
            goPage = (state.subloc == login) ? base : state.subloc;
          }
        }else{
          if (cus.isUserAutenticado == IsLoged.isAnonimo) {
            goPage = login;
          }else{
            goPage = (goPage == splash) ? splash : login;
          }
        }

        return (goPage == state.subloc) ? null : goPage;
      },
      refreshListenable: cus,
      debugLogDiagnostics: false
    );
  }


}