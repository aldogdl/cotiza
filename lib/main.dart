import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:camera/camera.dart' show availableCameras;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show
RemoteMessage, FirebaseMessaging;
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'src/providers/btn_send_cotizacion_prov.dart';
import 'src/providers/check_login.dart';
import 'src/providers/pestanias_prov.dart';
import 'src/providers/repos_proceso_prov.dart';
import 'src/providers/repos_pendientes_prov.dart';
import 'src/providers/pzas_to_cotizar_prov.dart';
import 'config/routes/route_config.dart';
import 'config/sng_manager.dart';
import 'src/services/pushes_service.dart';
import 'vars/globals.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  bool existe = await PushesService.existeId(msg.messageId);
  if(!existe){
    await PushesService.setNewMsg(msg);
  }
  await FlutterRingtonePlayer.playNotification(
    asAlarm: true, volume: 1, looping: false
  );
}

// adb shell am start -a android.intent.action.VIEW \ -c android.intent.category.BROWSABLE \ -d "https://autoparnet.com/cotiza/"

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  sngManager();
  await Hive.initFlutter();
  final global = getSngOf<Globals>();
  final cameras = await availableCameras();
  global.firstCamera = cameras.first;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (_) {}
  runApp(const AltaProveedores());
}

class AltaProveedores extends StatelessWidget {

  const AltaProveedores({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CheckLoginProvider()),
        ChangeNotifierProvider(create: (context) => ReposPendientesProv()),
        ChangeNotifierProvider(create: (context) => ReposProcesoProv()),
        ChangeNotifierProvider(create: (context) => PzasToCotizarProv()),
        ChangeNotifierProvider(create: (context) => PestaniasProv()),
        ChangeNotifierProvider(create: (context) => BtnSendCotizacionProv()),
      ],
      child: const MiddleWare(),
    );
  }
}

class MiddleWare extends StatelessWidget {

  const MiddleWare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double densityAmt = (getSngOf<Globals>().isMobileDevice) ? 0.0 : -1.0;
    VisualDensity density = VisualDensity(horizontal: densityAmt, vertical: densityAmt);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light
    ));

    final rutas = RutasConfig.rutas(context);
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Autoparnet Cotiza',
      theme: ThemeData(
        visualDensity: density,
        primarySwatch: Colors.green
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const[
        Locale('es', 'ES_MX'),
      ],
      color: Colors.black,
      routeInformationParser: rutas.routeInformationParser,
      routerDelegate: rutas.routerDelegate,
    );
  }
}
