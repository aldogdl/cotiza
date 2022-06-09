import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/src/providers/btn_send_cotizacion_prov.dart';
import 'package:autoparnet_cotiza/src/repository/automovil.dart';
import 'package:autoparnet_cotiza/src/repository/repos_repository.dart';

class RefCotiz {

  final Globals globals = getSngOf<Globals>();
  final RepoRepository repoEm = RepoRepository();
  final AutomovilRepository _autoEm = AutomovilRepository();
  final NumberFormat f = NumberFormat.currency(customPattern: "\$ #,##0.0#", decimalDigits: 2, locale: 'en_US');
  
  // Utilizada para la web, en caso de querer editar una pieza antes de enviar.
  bool isEditWeb = false;
  int keyPiezaEdit = -1;
  
  List<String> lugar = ['IZQUIERDO', 'DERECHO', 'CENTRAL', 'SUPERIOR', 'INFERIOR'];
  List<String> posic = ['DELANTERA', 'TRASERA', 'LATERAL', 'MOTOR', 'SUSPENSION'];
  List<String> origenes = ['SEMINUEVA ORIGINAL', 'GENÉRICA NUEVA', 'CUALQUIER ORÍGEN'];

  ///
  Future<bool?> showDialogAndSendPedido(BuildContext context, Map<String, dynamic> dataSend) async {

    double ancho = (kIsWeb) ? 0.5 : 0.8;
    bool? abosorbing;
    String btnSend = 'CONTINUAR';
    final prov = context.read<BtnSendCotizacionProv>();
    final nav  = Navigator.of(context);

    return await showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (_) {
        return AlertDialog(
          scrollable: true,
          insetPadding: (!kIsWeb) ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          titlePadding: const EdgeInsets.all(0),
          content: StatefulBuilder(
            builder: (_, StateSetter setStateSelf){

              if(abosorbing == null) {
                abosorbing = false;
                btnSend = 'CONTINUAR';
              }else{
                btnSend = 'ENVIANDO';
              }

              return SizedBox(
                width: MediaQuery.of(context).size.width * ancho,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: SvgPicture.asset(
                        'assets/svgs/buy_end.svg',
                        semanticsLabel: 'Enviando Datos',
                        alignment: Alignment.topCenter,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'AutoparNet, te agradece tu confianza, no estarás solo en el proceso del pedido, un Asesor se comunicará para darte información del seguimiento y resolver dudas e inquietudes.',
                      textScaleFactor: 1,
                      textAlign: TextAlign.center,
                      style: globals.styleText(17, Colors.black, false, sw: 1.1),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'El monto total de tu Solicitud es de:',
                      textScaleFactor: 1,
                      textAlign: TextAlign.center,
                      style: globals.styleText(17, Colors.black, true),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      f.format(dataSend['monto']),
                      textScaleFactor: 1,
                      textAlign: TextAlign.center,
                      style: globals.styleText(25, Colors.orange, true),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'El Monto podrás liquidarlo en contra entrega, después de revisar las refacciones y haber cubierto tus expectativas. Recuerda que cuentas con 5 días de GARANTÍA.',
                      textScaleFactor: 1,
                      textAlign: TextAlign.center,
                      style: globals.styleText(17, Colors.blue, false, sw: 1.1),
                    ),
                    const Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AbsorbPointer(
                          absorbing: abosorbing!,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.red)
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'CANCELAR',
                              textScaleFactor: 1,
                              style: globals.styleText(15, Colors.white, true),
                            )
                          ),
                        ),
                        AbsorbPointer(
                          absorbing: abosorbing!,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.purple)
                            ),
                            onPressed: () async {
                              
                              setStateSelf((){ abosorbing = true; });
                              await sendPedido(dataSend['data']);
                              prov.activeBtnSend = false;
                              nav.pop(true);
                            },
                            child: Text(
                              btnSend,
                              textScaleFactor: 1,
                              style: globals.styleText(15, Colors.white, true),
                            )
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.maxFinite,
                      color: const Color(0xff232323),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Text(
                        '¡Gracias por tu Pedido!',
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: globals.styleText(20, Colors.green, true),
                      ),
                    ),
                    if(abosorbing!)
                      const LinearProgressIndicator(),
                  ],
                ),
              );
            },
          ),
        );
      }
    );
  }

  ///
  Future<void> sendPedido(List<Map<String, dynamic>> ids) async {
    
    await repoEm.sendPedidoToSCP(ids);
    if(!repoEm.result['abort']) {
      globals.statusPedida = repoEm.result['body'];
      sendPushPedido(ids.first['main']);
    }
  }

  ///
  Future<void> sendPushPedido(int idMain) async => await repoEm.sendPushPedidoToSCP(idMain);

  ///
  Stream<String> downloadReposCurrents(String seccion) async* {

    String est = (seccion == 'pendientes') ? '1' : '2';

    const  duration = Duration(milliseconds: 200);
    await repoEm.getOrdenesByIdUserAndSeccion(globals.idUser, est);

    if(!repoEm.result['abort']) {
      
      List<Map<String, dynamic>>? ordenes = List<Map<String, dynamic>>.from(repoEm.result['body']);

      if(ordenes.isNotEmpty) {
        
        yield 'Guardando Elementos';
        await Future.delayed(duration);
        await repoEm.saveOrdenesFromServerInBdLocal(ordenes);
        repoEm.cleanResult();

        yield 'Revisando Marcas y Modelos';
        await Future.delayed(duration);
        await _autoEm.revisarExistMarcaAndModelos(ordenes);
        repoEm.cleanResult();

        yield 'Revisando Piezas';
        await Future.delayed(duration);
        List<int> ords = [];
        for (var i = 0; i < ordenes.length; i++) {
          if(!ords.contains(ordenes[i]['o_id'])) {
            ords.add(ordenes[i]['o_id']);
          }
        }
        if(ords.isNotEmpty) {
          await repoEm.getPiezasByLstOrdenes(ords.join('::'));
          if(!repoEm.result['abort']) {
            await repoEm.setPiezasFromServerToBdLocal(
              List<Map<String, dynamic>>.from(repoEm.result['body'])
            );
          }
          repoEm.cleanResult();
        }
      }

      yield 'Listo';
    }else{
      yield 'Listo';
    }
  }

}