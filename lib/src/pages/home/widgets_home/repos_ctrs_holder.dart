import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';

class ReposCtrlHolder extends StatefulWidget {

  final String titulo;
  final String subtitulo;
  final String desc;
  final String seccion;
  final bool isOf;
  final ValueChanged<String> onRefresh;

  const ReposCtrlHolder({
    Key? key,
    required this.titulo,
    required this.subtitulo,
    required this.desc,
    required this.seccion,
    required this.isOf,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<ReposCtrlHolder> createState() => _ReposCtrlHolderState();
}

class _ReposCtrlHolderState extends State<ReposCtrlHolder> {

  final globals = getSngOf<Globals>();
  final refCotiz = getSngOf<RefCotiz>();

  bool _isRefresing = false;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          _body(),
          if(_isRefresing)
            Positioned.fill(
              child: StreamBuilder<String>(
                stream: refCotiz.downloadReposCurrents(widget.seccion),
                builder: (_, AsyncSnapshot<String> snap) {
                  
                  if(snap.data == 'Listo') {
                    Future.delayed(const Duration(microseconds: 1000), (){
                      _endDownLoad();
                    });
                  }
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: Text(
                        snap.data ?? 'Espera...',
                        textScaleFactor: 1,
                        style: globals.styleText(12, Colors.green[200]!, false),
                      ),
                    ),
                  );
                },
              )
            ),
        ],
      ),
    );
  }

  ///
  Widget _body() {

    Color bgTitulo = Colors.green;
    if(widget.isOf) {
      bgTitulo = const Color(0xff303030);
    }

    double mh = (kIsWeb) ? 20 : 8;

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: mh, vertical: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xff232323),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff505050), width: 1)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 3, right: 3, bottom: 3, left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      colors: [
                        bgTitulo,
                        bgTitulo,
                        bgTitulo,
                        bgTitulo,
                        Colors.transparent,
                        Colors.transparent
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight
                    )
                  ),
                  child: Text(
                    widget.titulo,
                    textScaleFactor: 1,
                    style: globals.styleText(14, Colors.white, false, sw: 1.1),
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: const Color(0xff303030),
                child: Text(
                  '0',
                  textScaleFactor: 1,
                  style: globals.styleText(18, const Color(0xffcccccc), true),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if(widget.titulo == 'CALCULANDO...')
                      CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    const Icon(Icons.settings, size: 20, color: Colors.white)
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.subtitulo,
                      textScaleFactor: 1,
                      style: globals.styleText(14, Colors.grey, true, sw: 1.1),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          widget.desc,
                          textScaleFactor: 1,
                          style: globals.styleText(12, const Color(0xff909090), false, sw: 1.1),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 5),
          const Divider(
            color: Color(0xff303030), height: 3,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xff303030),
                  child: _widget(),
                ),
              ),
              _btnAccionBySeccion(),
              const SizedBox(width: 10),
              _btnAccionBySeccion(),
              const SizedBox(width: 10),
              _btnAccionBySeccion(),
              _btnAccionBySeccion()
            ],
          )
        ],
      ),
    );
  }
  
  ///
  Widget _btnAccionBySeccion() {

    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xff303030),
      ),
    );
  }

  ///
  Widget _widget() {
    
    return (!_isRefresing)
    ? IconButton(
      onPressed: () => _refresh(),
      icon: const Icon(
        Icons.refresh,
        color: Color(0xff999999),
        size: 18,
      )
    )
    : const SizedBox(
      width: 30, height: 30,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(3),
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  ///
  Future<void> _refresh() async => setState(() { _isRefresing = true; });

  ///
  Future<void> _endDownLoad() async {

    setState(() { _isRefresing = false; });
    widget.onRefresh('Listo');
  }
}