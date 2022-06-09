import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';

import '../data_shared/ds_repo.dart';
import '../../../providers/repos_proceso_prov.dart';
import '../../../providers/repos_pendientes_prov.dart';
import '../../../services/get_uris.dart';

class ReposCtrls extends StatefulWidget {

  final String tipo;
  final bool? hasNotif;
  final ValueChanged<void> onTap;
  final ValueChanged<void> onNext;
  final ValueChanged<void> onBack;
  final ValueChanged<void> onSee;
  final ValueChanged<void> onRefresh;
  final ValueChanged<void>? onDelete;

  const ReposCtrls({
    Key? key,
    required this.tipo,
    required this.onTap,
    required this.onNext,
    required this.onBack,
    required this.onSee,
    required this.onRefresh,
    this.hasNotif,
    this.onDelete
  }) : super(key: key);

  @override
  State<ReposCtrls> createState() => _ReposCtrlsState();
}

class _ReposCtrlsState extends State<ReposCtrls> {

  final globals = getSngOf<Globals>();
  final refCotiz = getSngOf<RefCotiz>();
  final dsRepo = getSngOf<DsRepo>();
  
  bool _isRefresing = false;

  @override
  void initState() {
    dsRepo.sttEm.openBoxStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          _containerSeccion(context),
          if(_isRefresing)
            Positioned.fill(
              child: _refreshOrdenes()
            ),
        ],
      ),
    );
  }

  ///
  Widget _refreshOrdenes() {

    return StreamBuilder<String>(
      stream: refCotiz.downloadReposCurrents(widget.tipo.toLowerCase()),
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
              snap.data ?? 'Espera, por favor',
              textScaleFactor: 1,
              style: globals.styleText(12, Colors.green[200]!, false),
            ),
          ),
        );
      },
    );
  }

  ///
  Widget _containerSeccion(BuildContext context) {

    Color bg = const Color.fromARGB(255, 3, 104, 187);
    Color fg = Colors.white;
    Color colorMain = Colors.blue.withOpacity(0.3);
    String msgToolTip = 'Click para Ver Cotización';

    var orden = context.read<ReposProcesoProv>().inSceneRepo;
    int cantOrds = context.read<ReposProcesoProv>().allKeys.length;
    
    switch (widget.tipo) {
      case 'PENDIENTES':
        orden = context.read<ReposPendientesProv>().inSceneRepo;
        cantOrds = context.read<ReposPendientesProv>().allKeys.length;
        msgToolTip = 'Click para Continuar';
        bg = Colors.red;
        break;
    }
    
    String logoMrk = (orden['logo'] != '0') ? orden['logo'] : 'no-logo.png';
    
    double mh = (kIsWeb) ? 20 : 8;

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: mh, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 41, 41, 41),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorMain, width: 1)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: msgToolTip,
            child: InkWell(
              onTap: () => widget.onTap(null),
              mouseCursor: SystemMouseCursors.click,
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
                          padding: const EdgeInsets.only(top: 3, right: 3, bottom: 3, left: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 51, 51, 51),
                                Colors.transparent
                              ],
                              stops: [0.8,1],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight
                            )
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.grey.withOpacity(0.4)
                                ),
                                child: Text(
                                  '$cantOrds',
                                  textScaleFactor: 1,
                                  style: globals.styleText(14, Colors.grey[200]!, false, sw: 1.1),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.tipo,
                                textScaleFactor: 1,
                                style: globals.styleText(14, Colors.white, false, sw: 1.1),
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'ORDEN:',
                            textScaleFactor: 1,
                            style: globals.styleText(13, fg, true),
                          ),
                          const SizedBox(width: 5),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: bg,
                            child: Text(
                              '${orden['idMain']}',
                              textScaleFactor: 1,
                              style: globals.styleText(12, fg, false),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: '${GetUris.getUriLogoMarcas()}/$logoMrk',
                              placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator()
                              ),
                              errorWidget: (_, msg, err) {
                                return const Image(
                                  image: AssetImage('assets/images/no-logo.png'),
                                );
                              },
                              fit: BoxFit.scaleDown
                            ),
                          )
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${orden['modelo']} - ${orden['anio']}',
                              textScaleFactor: 1,
                              style: globals.styleText(17, Colors.grey[400]!, true, sw: 1.1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  '${orden['nac']}',
                                  textScaleFactor: 1,
                                  style: globals.styleText(12, const Color(0xff909090), false, sw: 1.1),
                                ),
                                const Spacer(),
                                FutureBuilder(
                                  future: dsRepo.sttEm.toTexto(orden['est'], orden['stt']),
                                  builder: (_, AsyncSnapshot txt) {

                                    Color sttColor;
                                    if(txt.hasData) {
                                      sttColor = dsRepo.sttEm.getColor(txt.data);
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
                                
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Divider(
            color: Color(0xff303030), height: 3,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if(widget.tipo != 'PENDIENTES')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Pzas.',
                      textScaleFactor: 1,
                      style: globals.styleText(11, Colors.grey[400]!, false),
                    ),
                    Text(
                      '${orden['cantPzs']}',
                      textScaleFactor: 1,
                      textAlign: TextAlign.center,
                      style: globals.styleText(14, Colors.white, false),
                    )
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 5, top: 5),
                  child: Icon(Icons.label_important, size: 13, color: Colors.grey.withOpacity(0.3)),
                ),
              const SizedBox(width: 10),
              if(widget.hasNotif != null)
                Icon(
                  (widget.hasNotif ?? false) ? Icons.notifications_active : Icons.notifications,
                  size: 20,
                  color: (widget.hasNotif ?? false) ? Colors.yellow : Colors.white.withOpacity(0.1),
                ),
              const Spacer(),
              ..._btnAcciones(orden['idMain'])
            ],
          )
        ],
      ),
    );
  }

  ///
  List<Widget> _btnAcciones(int ordenCurrent) {

    return [
      _btnAccionBySeccion(
        icono: Icons.refresh,
        tooltip: 'Refrescar',
        fnc: () => _refresh()
      ),
      if(widget.tipo == 'PENDIENTES')
        _btnAccionBySeccion(
          icono: Icons.delete,
          tooltip: 'Eliminar',
          fnc: (widget.onDelete != null) ? () => widget.onDelete!(null) : null
        ),
      const SizedBox(width: 10),
      _btnAccionBySeccion(
        icono: Icons.list,
        tooltip: 'Ver Todas',
        fnc: () => widget.onSee(null)
      ),
      const SizedBox(width: 10),
      _btnAccionBySeccion(
        icono: Icons.arrow_back_ios_new_rounded,
        tooltip: 'Anterior',
        withoutCircle: true,
        isDense: true,
        fnc: () => widget.onBack(null)
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey.withOpacity(0.4)
        ),
        child: Text(
          (!kIsWeb) ? 'O: $ordenCurrent' : 'ORD: $ordenCurrent',
          textScaleFactor: 1,
          style: globals.styleText(12, Colors.grey[200]!, false, sw: 1.1),
        ),
      ),
      _btnAccionBySeccion(
        icono: Icons.arrow_forward_ios_rounded,
        tooltip: 'Siguiente',
        withoutCircle: true,
        isDense: true,
        fnc: () => widget.onNext(null)
      )
    ];
  }

  ///
  Widget _btnAccionBySeccion({
    required IconData icono,
    required String tooltip,
    required Function? fnc,
    bool withoutCircle = false,
    bool isDense = false,
  }) {

    Widget child = IconButton(
      tooltip: tooltip,
      onPressed: () => fnc!(),
      icon: Icon(
        icono,
        color: (icono == Icons.delete) ? Colors.orange : const Color(0xff999999),
        size: 18,
      )
    );

    return Container(
      padding: (isDense) ? null : const EdgeInsets.symmetric(horizontal: 3),
      child: (withoutCircle)
      ? child
      : CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xff303030),
          child: child,
        ),
    );
  }

  ///
  Future<void> _refresh() async => setState(() { _isRefresing = true; });

  ///
  Future<void> _endDownLoad() async {

    setState(() { _isRefresing = false; });
    widget.onRefresh(null);
  }
}
