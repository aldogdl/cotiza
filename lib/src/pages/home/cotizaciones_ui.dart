import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import 'widgets_home/lienzo_content.dart';
import '../respuestas/pieza_deta.dart';
import '../respuestas/resp_deta.dart';
import '../respuestas/respuestas_page.dart';


class CotizacionesUI extends StatelessWidget {

  final BoxConstraints constraints;
  CotizacionesUI({
    required this.constraints,
    Key? key
  }) : super(key: key);

  final globals = getSngOf<Globals>();
  final refCotiz = getSngOf<RefCotiz>();
  final ScrollController _ctrScroll = ScrollController();
  final ValueNotifier<Map<String, dynamic>> _showDataItem = ValueNotifier<Map<String, dynamic>>({});


  @override
  Widget build(BuildContext context) {

    return LienzoContent(
      constraints: constraints,
      child: _body(context)
    );
  }

  ///
  Widget _body(BuildContext context) {

    String bp = globals.getDeviceFromConstraints(constraints);
    
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5, right: 0),
      constraints: constraints,
      child: (bp == 'mediumHandset')
      ? SizedBox.expand(
        child: ListView(
          controller: _ctrScroll,
          children: _contenido(
            context,
            width: (kIsWeb) ? constraints.maxWidth : MediaQuery.of(context).size.width,
            height: constraints.maxHeight
          ),
        ),
      )
      :
      Row(
        children: _contenido(
          context,
          width: (constraints.maxWidth * 0.5) - 10
        ),
      ),
    );
  }

  ///
  List<Widget> _contenido(BuildContext context, {
    required double width,
    double? height,
  }) {

    return [
      Container(
        width: width * 0.871,
        height: height,
        color: const Color(0xFFeeeeee),
        child: Container(
          color: Colors.white,
          child: RespuestasPage(
            keyRepoMain: -1,
            onSendMobil: (_){},
            onSelected: (Map<String, dynamic> who) {
              _showDataItem.value = {};
              Future.delayed(const Duration(milliseconds: 200), (){
                _showDataItem.value = who;
              });
            }
          ),
        ),
      ),
      Container(
        width: width + (width * 0.15),
        height: height,
        color: const Color(0xFF333333),
        child: ValueListenableBuilder<Map<String, dynamic>>(
          valueListenable: _showDataItem,
          builder: (_, who, __) {

            if(who.isNotEmpty) {
              if(who['who'] == 'resp') {
                return RespDeta(
                  scrollCtr: _ctrScroll,
                  maxWidth: width,
                  resp: who['item'],
                  idRepoMain: who['idRepo']
                );
              }else{
                return PiezaDeta(
                  scrollCtr: _ctrScroll,
                  maxWidth: width,
                  pza: who['item'].toJson(),
                  idRepoMain: who['idRepo']
                );
              }
            }
            
            return SingleChildScrollView(
              controller: _ctrScroll,
              child: SizedBox(
                width: width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Icon(
                    Icons.visibility_outlined,
                    size: MediaQuery.of(context).size.width * 0.3,
                    color: const Color(0xFF232323).withOpacity(0.5),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

}