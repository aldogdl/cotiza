import 'package:autoparnet_cotiza/src/entity/orden_piezas.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/ref_cotiz.dart';
import 'package:autoparnet_cotiza/vars/scroll_config.dart';

import 'pieza_deta.dart';
import 'resp_deta.dart';
import '../home/data_shared/ds_repo.dart';
import '../home/widgets_home/repos_card.dart';
import '../../providers/btn_send_cotizacion_prov.dart';
import '../../repository/repos_repository.dart';
import '../../services/get_uris.dart';


class RespuestasPage extends StatefulWidget {

  final int keyRepoMain;
  final ValueChanged<Map<String, dynamic>>? onSelected;
  final ValueChanged<void> onSendMobil;
  const RespuestasPage({
    Key? key,
    required this.keyRepoMain,
    required this.onSendMobil,
    this.onSelected,
  }) : super(key: key);

  @override
  State<RespuestasPage> createState() => _RespuestasPageState();
}

class _RespuestasPageState extends State<RespuestasPage> {

  final DsRepo _dsRepo = getSngOf<DsRepo>();
  final Globals globals = getSngOf<Globals>();
  final RefCotiz refCotiz = getSngOf<RefCotiz>();
  final RepoRepository _repoEm = RepoRepository();

  final ScrollController _ctrScrollResp = ScrollController();

  final _select = ValueNotifier(<int>[]);
  final ValueNotifier<double> _totalSelect = ValueNotifier<double>(0.0);
  late final ValueNotifier<Map<String, dynamic>> _changePrecioTotal;

  final Map<String, dynamic> _pieHead = {'pzas': 0, 'resp': 0, 'precioLess': 0.0};
  final _hoyEs = DateTime.now();

  late final NumberFormat f;

  double ratio = 0.13;
  Box<OrdenPiezas>? piezas;
  List<OrdenPiezas> pzas = [];
  List<Map<String, dynamic>> lstResp = [];
  bool filtrar = false;

  @override
  void initState() {
    f = NumberFormat.currency(customPattern: "\$ #,##0.0#", decimalDigits: 2, locale: 'en_US');
    _changePrecioTotal  = ValueNotifier<Map<String, dynamic>>(_pieHead);
    super.initState();
  }

  @override
  void dispose() {
    _select.dispose();
    _totalSelect.dispose();
    _changePrecioTotal.dispose();
    _ctrScrollResp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: (kIsWeb) ? false : true,
        title: Text(
          'LISTA DE RESPUESTAS PARA...',
          textScaleFactor: 1,
          style: globals.styleText(13, Colors.white, true),
        ),
        actions: [
          _btnFiltrar()
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getRepoMainSelected(),
          builder: (_, AsyncSnapshot snapshot) {

            if(snapshot.connectionState == ConnectionState.done) {

              if(snapshot.hasData) {
                return Column(
                  children: [
                    ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: _changePrecioTotal,
                      builder: (_, newValue, __) {

                        return Container(
                          color: const Color(0xFF232323),
                          child: ReposCard(
                            showOnlyPie: true,
                            repoMain: snapshot.data, constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width,
                              maxHeight: MediaQuery.of(context).size.height * 0.1
                            ),
                            pieData: _pieHead,
                          ),
                        );
                      }
                    ),

                    if(!kIsWeb)
                      Container(
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.03,
                        child: CustomPaint(painter: Adorno()),
                      ),
                    Expanded(
                      child: _buildListaDePiezas()
                    ),
                    if(!kIsWeb)
                      _btnSendPedidoForApp()
                  ],
                );
              }else{
                return const Center(
                  child: Text('No se encontró la Solicitud')
                );
              }
            }

            return const Center(
              child: SizedBox(
                height: 25, width: 25,
                child: CircularProgressIndicator()
              ),
            );
          },
        ),
      ),
    );
  }

  ///
  Widget _btnSendPedidoForApp() {

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        )
      ),
      child: Consumer<BtnSendCotizacionProv>(
        builder: (_, provBtn, __) {
          
          return AbsorbPointer(
            absorbing: !provBtn.activeBtnSend,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.05,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                    backgroundColor: MaterialStateProperty.all(
                      (provBtn.activeBtnSend) ? Colors.blue : const Color(0xff232323)
                    ),
                    foregroundColor: MaterialStateProperty.all(
                      (provBtn.activeBtnSend) ? Colors.white : Colors.grey[800]!
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: (provBtn.activeBtnSend) ? () => widget.onSendMobil(null) : null,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: Text(
                    'Hacer Pedido',
                    textScaleFactor: 1,
                    style: globals.styleText(17, Colors.white, true),
                  )
                ),
              ),
            ),
          );
        },
      )
      
    );
  }

  ///
  Widget _btnFiltrar() {

    return ValueListenableBuilder<List<int>>(
      valueListenable: _select,
      builder: (_, inShop, __) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    filtrar = !filtrar;
                  });
                },
                icon: Icon(
                  (filtrar)
                    ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined,
                  size: 30
                )
              ),
              if(inShop.isNotEmpty)
                Positioned(
                  right: 0, top: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 10,
                    child: Text(
                      '${inShop.length}',
                      textScaleFactor: 1,
                      style: globals.styleText(11, Colors.white, true),
                    ),
                  )
                )
            ],
          ),
        );
      }
    );
  }
  
  ///
  Widget _buildListaDePiezas() {

    if(pzas.isNotEmpty) {

      Widget lstResp = ListView.builder(
        controller: _ctrScrollResp,
        padding: const EdgeInsets.only(right: 15),
        itemCount: pzas.length,
        shrinkWrap: true,
        itemBuilder: (_, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _laPieza(index),
            _respuestasDraw(index)
          ],
        )
      );

      if(kIsWeb) {
        return _putScroll( child: lstResp );
      }
      return lstResp;

    }else{
      return Center(
        child: Text(
          'SECCIÓN DE RESPUESTAS\nSelecciona una Solicitud para\nVisualizar Respuestas',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: globals.styleText(19, Colors.grey, false),
        )
      );
    }
  }

  ///
  Widget _putScroll({required Widget child}) {

    return ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: Scrollbar(
          controller: _ctrScrollResp,
          thumbVisibility: true,
          radius: const Radius.circular(0),
          child: child,
        )
      );
  }

  ///
  Widget _laPieza(int index) {

    if(kIsWeb) { ratio = 0.05; }

    return ListTile(
      onTap: () {
        if(kIsWeb) {
          widget.onSelected!({
            'item': pzas[index], 'idRepo':pzas[index].orden, 'who':'pza'
          });
        }else{
          _showDataPiezaInMobil(index);
        }
      },
      tileColor: Colors.grey[200],
      dense: true,
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: _determinarFoto(index)
      ),
      title: Text(
        pzas[index].piezaName,
        textScaleFactor: 1,
        textAlign: TextAlign.start,
        style: globals.styleText(17, Colors.black, true),
      ),
      subtitle: Text(
        '${ pzas[index].lado }/${ pzas[index].posicion }',
        textScaleFactor: 1,
        textAlign: TextAlign.start,
        style: globals.styleText(13, Colors.grey, false),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF232323),
              borderRadius: BorderRadius.circular(5)
            ),
            child: ValueListenableBuilder(
              valueListenable: _totalSelect,
              builder: (_, newval, __) {
                return Text(
                  _recalcularTotales(pzas[index].id),
                  textScaleFactor: 1,
                  style: globals.styleText(12, Colors.white, true, sw: 1.1),
                );
              },
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'ID: ${pzas[index].id}',
            textScaleFactor: 1,
            style: globals.styleText(10, Colors.green, true, sw: 1.1),
          )
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      minLeadingWidth: MediaQuery.of(context).size.width * ratio,
    );
  }

  ///
  Widget _respuestasDraw(int index) {

    List<Map<String, dynamic>> resp = [];
    for (var i = 0; i < lstResp.length; i++) {
      if(lstResp[i]['pza_id'] == pzas[index].id) {
        resp.add(lstResp[i]);
      }
    }

    double margin = MediaQuery.of(context).size.width * (ratio/1.3);

    if(resp.isNotEmpty) {

      return Container(
        margin: EdgeInsets.only(left: margin),
        padding: const EdgeInsets.only(left: 10),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.grey, width: 1)
          )
        ),
        child: ValueListenableBuilder<List<int>>(
          valueListenable: _select,
          builder: (_, value, child){
            
            return LayoutBuilder(
              builder: (_, restrics) {
                return Column(
                  children: resp.map((respuesta){
                    if(filtrar) {
                      if(_select.value.contains(respuesta['info_id'])) {
                        return _containerRespuesta(respuesta, pzas[index].orden, restrics);
                      }else{
                        return const SizedBox(height: 0, width: 0);
                      }
                    }else{
                      return _containerRespuesta(respuesta, pzas[index].orden, restrics);
                    }
                  }).toList()
                );
              },
            );
          },
        ),
      );

    }else{

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          'Aún sin Respuestas',
          textScaleFactor: 1,
          textAlign: TextAlign.left,
          style: globals.styleText(15, Colors.red, true),
        ),
      );
    }
  }

  ///
  Widget _containerRespuesta(Map<String, dynamic> r, int idRepo, BoxConstraints restrics) {

    String caracteristicas = r['info_caracteristicas'];
    if(caracteristicas.contains('Orígen')) {
      int iniOrigen = caracteristicas.indexOf('Orígen');
      int finOrigen = caracteristicas.indexOf('-> ');
      String subStr = caracteristicas.substring(iniOrigen, finOrigen+2);
      caracteristicas = caracteristicas.replaceAll(subStr, '');
      caracteristicas = caracteristicas.trim();
    }

    double? precio = double.tryParse('${r['info_precio']}');
    bool isBad = true;
    if(precio != null) {
      if(precio > 0.0) {
        isBad = false;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: (){
                if(kIsWeb) {
                  widget.onSelected!({
                    'item': r, 'idRepo':idRepo, 'who':'resp'
                  });
                }else{
                  _verDetallesRespuesta(r, idRepo);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.format(r['info_precio']),
                      textScaleFactor: 1,
                      style: globals.styleText(17, Colors.purple, true),
                    ),
                    SizedBox(
                      width: restrics.maxWidth * 0.8,
                      child: Text(
                        caracteristicas,
                        softWrap: true,
                        textScaleFactor: 1,
                        overflow: TextOverflow.ellipsis,
                        style: globals.styleText(14, Colors.grey[600]!, false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Checkbox(
              side: BorderSide(
                color: (isBad) ? Colors.grey.withOpacity(0.5) : Colors.black
              ),
              visualDensity: VisualDensity.compact,
              value: _select.value.contains(r['info_id']),
              onChanged: (val) => _seleccionarRespuesta(r)
            )
          ],
        ),
        Row(
          children: [
            Text(
              'ID: ${r['info_id']}',
              textScaleFactor: 1,
              style: globals.styleText(12, Colors.blue, false),
            ),
            const SizedBox(width: 10),
            Text(
              formatearFecha(r['info_createdAt']),
              textScaleFactor: 1,
              style: globals.styleText(12, Colors.black, false),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 10)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  elevation: MaterialStateProperty.all(0)
                ),
                onPressed: () {
                  if(!isBad) {
                    if(kIsWeb) {
                      widget.onSelected!({
                        'item': r, 'idRepo':idRepo, 'who':'resp'
                      });
                    }else{
                      _verDetallesRespuesta(r, idRepo);
                    }
                  }
                },
                child: Text(
                  'Ver Detalles',
                  textScaleFactor: (kIsWeb) ? 0.8 : 1,
                  style: globals.styleText(
                    15,
                    (isBad) ? Colors.grey.withOpacity(0.5) : Colors.red,
                    true
                  )
                ),
              ),
            )
          ],
        ),
        const Divider(
          color: Colors.green,
          height: (kIsWeb) ? 7 : 2,
        )  
      ],
    );
  }
  
  ///
  ImageProvider _determinarFoto(int index) {

    late ImageProvider imgPzaFirst;
    if(pzas[index].fotos.isNotEmpty) {
      imgPzaFirst = CachedNetworkImageProvider(
        GetUris.getUriFotoPzaBeforeCot(pzas[index].fotos.first),
        errorListener: () => Image.asset('assets/images/no-logo.png'),
      );
    }else{
      imgPzaFirst = const AssetImage('assets/images/no-logo.png');
    }
    return imgPzaFirst;
  }

  ///
  void _verDetallesRespuesta(Map<String, dynamic> resp, int idRepoMain) async {

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff232323),
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: RespDeta(
            resp: resp,
            scrollCtr: _ctrScrollResp,
            maxWidth: MediaQuery.of(context).size.width,
            idRepoMain: idRepoMain
          )
        );
      }
    );
  }

  ///
  Future<Map<String, dynamic>> _getRepoMainSelected() async {

    _select.value = [];
    if(_dsRepo.idRepoMainSelectCurrent == 0) {
      return _dsRepo.getOrdenFromEntityToMapBy(0, keyOrden: widget.keyRepoMain);
    }
    await _dsRepo.openBoxOrdenPzas();
   
    Iterable<OrdenPiezas>? has = _dsRepo.ordenPzas.values.where((p) {
      return p.orden == _dsRepo.idRepoMainSelectCurrent;
    });
    if(has.isNotEmpty) {
      pzas = List<OrdenPiezas>.from(has);
    }
    _pieHead['pzas'] = pzas.length;

    has = null;
    if(_select.value.isEmpty) {
      await _getRespuestasByIdPieza();
    }
    if(widget.keyRepoMain == -1) {
      return _dsRepo.getOrdenFromEntityToMapBy(pzas.first.orden);
    }
    return _dsRepo.getOrdenFromEntityToMapBy(0, keyOrden: widget.keyRepoMain);
    
  }

  ///
  Future<void> _getRespuestasByIdPieza() async {

    // await _repoEm.getRespuestasByIdMain(_dsRepo.idRepoMainSelectCurrent);
    _repoEm.result['abort'] = true;
    if(!_repoEm.result['abort']) {
      lstResp = List<Map<String, dynamic>>.from(_repoEm.result['body']);
      if(lstResp.isNotEmpty) {
        
        final btn = context.read<BtnSendCotizacionProv>();
        _select.value = await _dsRepo.getRespuestaByIdRepoSelect();
        if(_select.value.isEmpty) {
          _repoEm.sendPushLeida(_dsRepo.idRepoMainSelectCurrent);
        }else{
          btn.activeBtnSend = true;
        }
        _pieHead['resp'] = lstResp.length;
        await _calcularGranTotal();
      }
    }
  }

  ///
  Future<void> _calcularGranTotal() async {

    double gtotal = 0;
    _pieHead['precioLess'] = 0;

    _select.value.map((sel) {
      Iterable<Map<String, dynamic>> ma = lstResp.where((element) => element['info_id'] == sel);
      if(ma.isNotEmpty) {
        gtotal = gtotal + ma.first['info_precio'];
      }
    }).toList();

    _pieHead['precioLess'] = gtotal;
    _changePrecioTotal.value = {};

    Future.delayed(const Duration(milliseconds: 200), () {
      _changePrecioTotal.value = _pieHead;
      final act = (gtotal > 0) ? true : false;
      context.read<BtnSendCotizacionProv>().activeBtnSend = act;
    });
  }

  ///
  String formatearFecha(String fecha) {

    String result = '';
    DateTime fech = DateTime.parse(fecha);
    if(_hoyEs.year == fech.year) {
      if(_hoyEs.month == fech.month) {
        if(_hoyEs.day == fech.day) {
          result = 'HOY a las: ${fech.hour}:${fech.minute}';      
        }
      }  
    }

    return (result.isEmpty) ? '${fech.day}-${fech.month}-${fech.year}' : result;
  }

  ///
  String _recalcularTotales(int idPza) {

    double total = 0;
    lstResp.map((e) {
      if(e['pza_id'] == idPza) {
        if(_select.value.contains(e['info_id'])) {
          total = total + e['info_precio'];
        }
      }
    }).toList();    
    return f.format(total);
  }

  ///
  void _seleccionarRespuesta(Map<String, dynamic> r) async {

    List<int> olds = List<int>.from(_select.value);

    if(olds.contains(r['info_id'])){

      olds.remove(r['info_id']);
      await _dsRepo.setRespuestaPedido(
        id: r['info_id'],
        idPza: r['pza_id'],
        idRepo: _dsRepo.idRepoMainSelectCurrent,
        precio: double.parse('${r['info_precio']}'),
        insert: false
      );
    }else{

      double? precio = double.tryParse('${r['info_precio']}');
      bool isBad = true;
      if(precio != null) {
        if(precio > 0.0) {
          isBad = false;
        }
      }

      if(isBad){ return; }

      olds.add(r['info_id']);
      await _dsRepo.setRespuestaPedido(
        id: r['info_id'],
        idPza: r['pza_id'],
        idRepo: _dsRepo.idRepoMainSelectCurrent,
        precio: double.parse('${r['info_precio']}'),
        insert: true
      );
    }
    _select.value = olds;
    _totalSelect.value = _totalSelect.value+1;
    await _calcularGranTotal();

  }

  ///
  void _showDataPiezaInMobil(int index) {

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff232323),
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: PiezaDeta(
            scrollCtr: _ctrScrollResp,
            maxWidth: MediaQuery.of(context).size.width,
            pza: pzas[index].toJson(),
            idRepoMain: pzas[index].orden
          )
        );
      }
    );
  }
  
}


class Adorno extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    
    Paint paint = Paint();
    paint.color = const Color(0xFF232323);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0;

    Paint paintfill = Paint();
    paintfill.color = const Color(0xFF232323);
    
    Path path = Path();
    Path path2 = Path();

    path2.moveTo(0, 0);
    path2.lineTo(size.width, 0);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, 0);

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, 0);
    canvas.drawPath(path2, paintfill);
    return canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}