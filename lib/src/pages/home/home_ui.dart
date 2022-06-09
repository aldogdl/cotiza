import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'home_der_ui.dart';
import 'home_izq_ui.dart';
import '../qr_reader/shared_fotos_from.dart';
import '../qr_reader/qr_reader.dart';

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final globals = getSngOf<Globals>();

  String _bp = '';
  double _maxH = 0.0;
  late BoxConstraints _constraints;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
             SizedBox(
              height: 40,
              child: Image(
                image: AssetImage('assets/images/ico_logo.png'),
              ),
            ),
          ]
        ),
        actions: [
          if(!kIsWeb)
            IconButton(
              onPressed: () => _openQrReader(),
              icon: const Icon(Icons.qr_code)
            )
        ],
        elevation: 2,
        backgroundColor: const Color(0xcc5FB131)
      ),
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (_, constraints) {
          
          _constraints = constraints;
          _bp = globals.getDeviceFromConstraints(constraints);
          _maxH = globals.getHeight(context);
          
          if(MediaQuery.of(context).size.width <= globals.tabletMax) {              
            if(kIsWeb && _bp == 'largeTablet' ) {
              return _avisoDeTamanioDelNavegador();
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: _maxH,
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  maxWidth: (_bp != 'mediumHandset') ? globals.maxIzq : MediaQuery.of(context).size.width,
                  minHeight: globals.minH
                ),
                child: HomeIzqUI(constraints: constraints),
              ),
              if(_bp != 'mediumHandset')
                Expanded(
                  child: Container(
                    color: Colors.black,
                    height: _maxH,
                    padding: const EdgeInsets.only(top: 25),
                    child: HomeDerUI()
                  ),
                )
            ],
          );
        }
      )
    );
  }

  ///
  Widget _avisoDeTamanioDelNavegador() {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Lo sentimos este sitio está diseñado para monitores con '
          'una resolución mayor a ${globals.tabletMax}px.',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: globals.styleText(40, Colors.amber, true),
        ),
        const SizedBox(height: 10),
        Text(
          'Recomendamos ampliamente visualizarla directamente '
          'en cualquier Celular o Dispositivo Móvil',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: globals.styleText(30, Colors.blue, false),
        )
      ],
    );
  }

  ///
  Future<void> _openQrReader() async {

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => QrReader(
          onReaded: (Map<String, String?> codeQr) {

            if(codeQr.isNotEmpty) {
              
              if(codeQr['code']!.startsWith('dtct')) {
                List? decod = codeQr['code']!.split('::');
                Map<String, dynamic> data = {
                  'contacto': decod[1].split('-').last,
                  'celular' : decod[2].split('-').last,
                  'telfijo' : decod[3].split('-').last,
                };
                decod = null;
                _datosDeContactoAction(data);
              }else{
                _sharedFotosFromQR(codeQr['code']!);
              }

            }else{
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Sin Lectura de Código',
                      textScaleFactor: 1,
                      style: globals.styleText(16, Colors.amber, true)
                    )
                  )
                ),
              );
            }
          }
        )
      )
    );
  }

  ///
  void _datosDeContactoAction(Map<String, dynamic> data) {

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${data['contacto']}',
                textScaleFactor: 1,
                style: globals.styleText(22, Colors.green, true),
              ),
              Text(
                'CONTACTANDO A...',
                textScaleFactor: 1,
                style: globals.styleText(14, Colors.grey, false),
              ),
              const Divider(),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  spacing: MediaQuery.of(context).size.width * 0.1,
                  children: [
                    _btnAccionContac(
                      icono: Icons.phone_android,
                      label: 'Directo al\nCelular',
                      acc: () {
                        final Uri launchUri = Uri(
                          scheme: 'tel',
                          path: data['celular'],
                        );
                        _urlLauncher(launchUri.toString());
                      }
                    ),
                    _btnAccionContac(
                      icono: Icons.message,
                      label: 'Mesajes\nWhatsapp',
                      acc: () => _urlLauncher(
                        'https://wa.me/52${data['celular']}/?text=Hola ${data['contacto']} buen día!!, puedo preguntarte por una refacción?'
                      )
                    ),
                    _btnAccionContac(
                      icono: Icons.call,
                      label: 'Sucursal\nTeléfono',
                      acc: () {
                        final Uri launchUri = Uri(
                          scheme: 'tel',
                          path: data['telfijo'],
                        );
                        _urlLauncher(launchUri.toString());
                      }
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  ///
  void _urlLauncher(String uri) async {
    
    final url = Uri.parse(uri);
    if(await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  ///
  void _sharedFotosFromQR(String code) {

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SharedFotosFrom(
          constraints: _constraints,
          codeQr: code,
          onFinish: (_) {
            Navigator.of(context).pop();
          },
        )
      )
    );
  }

  ///
  Widget _btnAccionContac({
    required IconData icono,
    required String label,
    required Function acc,
  }) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.width * 0.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green[800]!,
                Colors.green[900]!
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(15)
          ),
          child: IconButton(
            icon: Icon(icono, size: 35, color: Colors.white),
            onPressed: () => acc(),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: globals.styleText(14, Colors.grey, false),
        ),
      ],
    );
  }

}