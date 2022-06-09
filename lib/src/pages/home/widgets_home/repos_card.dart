import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import '../data_shared/ds_repo.dart';
import '../../../services/get_uris.dart';
import '../../../widgets/varios_widgets.dart';

class ReposCard extends StatefulWidget {

  final BoxConstraints constraints;
  final Map<String, dynamic> repoMain;
  final Map<String, dynamic>? pieData;
  final bool showOnlyPie;

  const ReposCard({
    required this.constraints,
    required this.repoMain,
    this.pieData,
    this.showOnlyPie = false,
    Key? key
  }) : super(key: key);

  @override
  State<ReposCard> createState() => _ReposCardState();
}

class _ReposCardState extends State<ReposCard> {

  final VariosWidgets variosWidgets = VariosWidgets();
  final globals = getSngOf<Globals>();
  final _dsRepo = getSngOf<DsRepo>();

  late Future<Map<String, dynamic>> getDataPie;
  late final NumberFormat f;
  double _maxW = 0;

  @override
  void initState() {

    f = NumberFormat.currency(customPattern: "\$ #,##0.0#", decimalDigits: 2, locale: 'en_US');
    if(widget.pieData == null) {
      getDataPie = _dsRepo.buildPieCardDataEnProceso(widget.repoMain['idMain']);
    }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    if(widget.repoMain.isEmpty) { return const SizedBox(); }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: LayoutBuilder(
        builder: (_, BoxConstraints cont) {
          return _body(cont);
        },
      ),
    );
  }

  ///
  Widget _body(BoxConstraints cont) {

    _maxW = globals.getMaxWidht(cont);
    double maxH = globals.getHeight(context);    
    double alto = (maxH <= 618) ? 93 : maxH * 0.17;
    if(kIsWeb) { alto = alto + 20; }else{ alto = alto + 15; }

    return Card(
      elevation: 0,
      shape: OutlineInputBorder(
        borderSide: BorderSide(
          color: (_dsRepo.idRepoMainSelectCurrent != widget.repoMain['idMain'])
          ? Colors.blue.withOpacity(0.3) : Colors.grey
        )
      ),
      color: (_dsRepo.idRepoMainSelectCurrent != widget.repoMain['idMain'])
          ? const Color.fromARGB(255, 41, 41, 41) : const Color.fromARGB(255, 53, 53, 53),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: (!widget.showOnlyPie) ? alto : null,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            if(!widget.showOnlyPie)
              ...[
                Expanded(child: _header()),
              ],
            _pie(),
          ]
        )
      )
    );
  }
  
  ///
  Widget _header() {

    return Row(
      children: [
        _dataAuto(),
        if(_maxW > 330)
          ...[
            const Spacer(),
            _logoMarca()
          ]
      ]
    );
  }

  ///
  Widget _dataAuto() {

    DateTime date = widget.repoMain['creada'];
    Color colorGradientFin = (_dsRepo.idRepoMainSelectCurrent != widget.repoMain['idMain'])
          ? const Color.fromARGB(255, 41, 41, 41) : const Color.fromARGB(255, 53, 53, 53);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: _maxW * 0.65,
          padding: const EdgeInsets.only(left: 10, top: 3, right: 3, bottom: 3),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 32, 32, 32),
                colorGradientFin
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${widget.repoMain['modelo']}',
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                style: globals.styleText(16, Colors.white.withOpacity(0.7), true)
              ),
              const SizedBox(width: 10),
              Text(
                '${widget.repoMain['anio']}',
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                style: globals.styleText(17, Colors.white.withOpacity(0.9), true)
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '${widget.repoMain['nac']}',
          textScaleFactor: 1,
          overflow: TextOverflow.ellipsis,
          style: globals.styleText(12, Colors.white.withOpacity(0.5), true)
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Fecha del: ${ date.day }-${ date.month }-${ date.year }',
              textScaleFactor: 1,
              style: globals.styleText(15, Colors.blue, false)
            ),
          ]
        ),
        const SizedBox(height: 5),
        FutureBuilder(
          future: _dsRepo.sttEm.toTexto(widget.repoMain['est'], widget.repoMain['stt']),
          builder: (_, AsyncSnapshot txt) {

            Color sttColor;
            if(txt.hasData) {
              sttColor = _dsRepo.sttEm.getColor(txt.data);
            }else{
              sttColor = const Color.fromARGB(255, 33, 243, 68);
            }
            return Text(
              txt.data ?? '...',
              textScaleFactor: 1,
              style: globals.styleText(13, sttColor, false, sw: 1.1),
            );
          },
        )
        // Text(
        //   '${widget.repoMain['stt']}',
        //   textScaleFactor: 1,
        //   overflow: TextOverflow.ellipsis,
        //   style: globals.styleText(
        //     12,
        //     (widget.repoMain['stt'].contains('enviar')) ? const Color.fromARGB(255, 33, 150, 243)  : const Color.fromARGB(255, 255, 235, 59),
        //     false
        //   )
        // ),
      ]
    );
  }
  
  ///
  Widget _logoMarca() {

    String logoMrk = (widget.repoMain['logo'] != '0')
      ? widget.repoMain['logo']
      : 'no-logo.png';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60),
        color: Colors.white,
      ),
      child: Center(
        child: CachedNetworkImage(
          imageUrl: '${GetUris.getUriLogoMarcas()}/$logoMrk',
          placeholder: (_, __) => const Center(
            child: SizedBox(
              width: 50, height: 50,
              child: CircularProgressIndicator()
            )
          ),
          errorWidget: (_, msg, err) {
            return const Image(
              image: AssetImage('assets/images/no-logo.png'),
            );
          },
          fit: BoxFit.scaleDown
        )
      ),
    );
  }

  ///
  Widget _pie() {

    if(widget.pieData != null){
      return _pieCotCards(widget.pieData!);
    }else{

      return FutureBuilder<Map<String, dynamic>>(
        future: getDataPie,
        builder: (_, AsyncSnapshot snapshot) {
          
          if(snapshot.connectionState == ConnectionState.done) {
            return _pieCotCards(snapshot.data);
          }
          return Text(
            'Calculando...',
            textScaleFactor: 1,
            style: globals.styleText(12, Colors.orange, true)
          );
        },
      );
    }
  }

  ///
  Widget _pieCotCards(Map<String, dynamic> data) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        
        Text(
          'Pzs: ',
          textScaleFactor: 1,
          overflow: TextOverflow.ellipsis,
          style: globals.styleText(14, Colors.green, false)
        ),
        Text(
          '${data['pzas']}',
          textScaleFactor: 1,
          overflow: TextOverflow.ellipsis,
          style: globals.styleText(15, Colors.grey, true)
        ),
        const SizedBox(width: 10),
        Text(
          'Rps: ',
          textScaleFactor: 1,
          overflow: TextOverflow.ellipsis,
          style: globals.styleText(14, Colors.green, false)
        ),
        Text(
          '${data['resp']}',
          textScaleFactor: 1,
          overflow: TextOverflow.ellipsis,
          style: globals.styleText(15, Colors.grey, true)
        ),
        if(!widget.showOnlyPie)
          ...[
            const SizedBox(width: 8),
            // Text(
            //   '${widget.repoMain['stt']}',
            //   textScaleFactor: 1,
            //   overflow: TextOverflow.ellipsis,
            //   style: globals.styleText(11, globals.getColorStatus(widget.repoMain['statusId']), false)
            // ),
          ],
        const Spacer(),
        Text(
          'ORDEN: ',
          textScaleFactor: 1,
          overflow: TextOverflow.ellipsis,
          style: globals.styleText(14, Colors.green, false)
        ),
        Text(
          '${widget.repoMain['idMain']}',
          textScaleFactor: 1,
          overflow: TextOverflow.ellipsis,
          style: globals.styleText(15, Colors.grey, true)
        ),
      ]
    );
  }


}