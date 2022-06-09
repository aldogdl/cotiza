import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChannels, SystemChrome, SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/routes/route_config.dart';
import '../../config/sng_manager.dart';
import '../providers/check_login.dart';
import '../services/fbm_google.dart';

class Base extends StatefulWidget {

  const Base({Key? key}) : super(key: key);

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {

  final seccThis = ['salir', 'none'];
  final fbm = getSngOf<FBMGoogle>();
  late Future<String> initCheck;
  late CheckLoginProvider _userProv;
  
  bool _isInit = false;

  @override
  void initState() {

    initCheck = _analizarIntro();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fbm.configMsgOn();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.green,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () => Future.value(false),
        child: SafeArea(
          child: FutureBuilder<String>(
            future: initCheck,
            builder: (_, snap) {

              if(snap.connectionState == ConnectionState.done) {
                if(snap.hasData) {
                  if(snap.data!.isNotEmpty) {
                    return _salir();
                  }
                }
              }
              return _logo();
            },
          )
        ),
      )
    );
  }

  ///
  Widget _logo() {

    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Center(
        child: SizedBox(
          width: size.width * 0.7,
          child: Image.asset('assets/images/splash_logo.png'),
        ),
      ),
    );
  }

  ///
  Widget _salir() {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Text(
            'Realmente deseas salir de:',
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w200,
              color: Color.fromARGB(255, 194, 194, 194)
            ),
          ),
          const Text(
            'Autoparnet Cotiza',
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 194, 194, 194)
            ),
          ),
          const SizedBox(height: 10),
          _btnAcc(
            label: 'SÍ, SALIR...', ico: Icons.close,
            fnc: () => SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop')
          ),
          _btnAcc(
            label: 'REGRESAR', ico: Icons.rotate_left_rounded,
            fnc: () => context.push(RutasConfig.bienvenido)
          )
        ],
      ),
    );
  }

  
  Widget _btnAcc({
    required IconData ico,
    required Function fnc,
    required String label,
  }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 73, 73, 73))
        ),
        onPressed: () => fnc(),
        icon: Icon(ico),
        label: Text(
          label,
          textScaleFactor: 1,
          style: const TextStyle(
            color: Colors.green,
            fontSize: 22,
          ),
        )
      )
    );
  }

  ///
  Future<String> _analizarIntro() async {

    if(!_isInit) {
      _isInit = true;
      _userProv = context.read<CheckLoginProvider>();
    }
    String page = '';
    if(_userProv.isUserAutenticado == IsLoged.isAutorized) {
      page = RutasConfig.bienvenido;
      Future.delayed(const Duration(milliseconds: 60), (){
        context.push(RutasConfig.bienvenido);
      });
    }

    return page;
  }
  
}