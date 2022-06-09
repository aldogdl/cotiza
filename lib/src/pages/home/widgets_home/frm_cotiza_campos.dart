import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import 'package:autoparnet_cotiza/vars/vals_constantes.dart';

import '../../../../config/sng_manager.dart';
import '../../../../vars/ref_cotiz.dart';
import '../../../providers/pzas_to_cotizar_prov.dart';
import '../../../services/get_uris.dart';
import '../../../services/my_http.dart';
import '../../../widgets/get_fotos/singleton/picker_pictures.dart';
import '../../../widgets/varios_widgets.dart';

class FrmCotizaCampos extends StatefulWidget {

  final double padding;
  final bool isMovil;
  final String brackPoint;
  final double sp;
  final bool showFotos;
  final int idOrden;
  final ValueChanged<void> onEditFotos;
  final ValueChanged<void> onTapTerminar;
  final ValueChanged<void> onTapAddmore;
  final ValueChanged<void> onScrollMoveTo;
  const FrmCotizaCampos({
    Key? key,
    required this.idOrden,
    required this.isMovil,
    required this.padding,
    required this.brackPoint,
    required this.sp,
    required this.showFotos,
    required this.onEditFotos,
    required this.onTapTerminar,
    required this.onTapAddmore,
    required this.onScrollMoveTo,
  }) : super(key: key);

  @override
  State<FrmCotizaCampos> createState() => _FrmCotizaCamposState();
}

class _FrmCotizaCamposState extends State<FrmCotizaCampos> {

  final _refCotz = getSngOf<RefCotiz>();
  final picktures = getSngOf<PickerPictures>();
  final GlobalKey<FormState> _keyFrm = GlobalKey<FormState>();
  late final PzasToCotizarProv pzaCurrent;

  final FocusNode _focusFrm = FocusNode();
  final SuggestionsBoxController _ctrSug = SuggestionsBoxController();
  final TextEditingController _ctrPieza = TextEditingController();
  final TextEditingController _ctrLado = TextEditingController();
  final TextEditingController _ctrPosi  = TextEditingController();
  final TextEditingController _ctrOrigen= TextEditingController();
  final TextEditingController _ctrNotas = TextEditingController();

  final FocusNode _focusCan = FocusNode();
  final FocusNode _focusPza = FocusNode();
  final FocusNode _focusLado = FocusNode();
  final FocusNode _focusPos = FocusNode();
  final FocusNode _focusOri = FocusNode();
  final FocusNode _focusNot = FocusNode();
  final FocusNode _lstFocusPzas = FocusNode();
  final VariosWidgets variosWidgets = VariosWidgets();
  
  late final Widget _sp;
  String _bp = 'mediumHandset';
  double altoLstPiezas = 0.333;
  List<Map<String, dynamic>> piezasRegs = [];
  List<Map<String, dynamic>> suggPiezas = [];
  bool _isInit = false;
  bool _showLinear = false;

  @override
  void initState() {
    
    _bp = widget.brackPoint;
    _sp = const SizedBox(height: ValoresConstantes.altoSp);
    if(_refCotz.keyPiezaEdit != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final pieza = await _refCotz.repoEm.getPiezasInLocalByKey(_refCotz.keyPiezaEdit);
        if(pieza != null) {
          _ctrPieza.text = pieza.piezaName;
          _ctrLado.text  = pieza.lado;
          _ctrPosi.text  = pieza.posicion;
          _ctrNotas.text = pieza.obs;
          _ctrOrigen.text= pieza.origen;
          pzaCurrent.pzaOfOrdenCurrent = pieza.toJson();
          picktures.idOrden = pieza.orden;
          picktures.idPiezaTmp = '${pieza.id}';
          setState(() {});
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {

    _focusFrm.dispose();
    _ctrPieza.dispose();
    _ctrLado.dispose();
    _ctrPosi.dispose();
    _ctrOrigen.dispose();
    _ctrNotas.dispose();
    _focusCan.dispose();
    _focusPza.dispose();
    _focusLado.dispose();
    _focusPos.dispose();
    _focusOri.dispose();
    _focusNot.dispose();
    _lstFocusPzas.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      pzaCurrent = context.read<PzasToCotizarProv>();
      _focusFrm.attach(context);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.padding),
      child: Focus(
        focusNode: _focusFrm,
        canRequestFocus: true,
        child: Form(
          key: _keyFrm,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: (widget.isMovil)
              ? Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: _buildListWidgetsFrm(),
              )
              : _buildListWidgetsFrm()
            )
        ),
      )
    );
  }

  ///
  Widget _buildListWidgetsFrm() {

    double sizeCurrent = MediaQuery.of(context).size.width - _refCotz.globals.maxIzq;

    if(sizeCurrent <= _refCotz.globals.tabletMin) {
      if(_bp != 'mediumHandset') {
        altoLstPiezas = 0.333;
        return _frmPzaTableta();
      }
    }

    altoLstPiezas = 0.18;

    return Column(
      children: [
        _fieldOrigenDePieza(),
        _sp,
        _fieldDropSearchPieza(),
        _sp,
        (sizeCurrent < 680)
        ? Column(
          children: [
             _fieldPosicion(),
             _sp,
             _fieldLado(),
          ],
        )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _fieldPosicion()),
              const SizedBox(width: 10),
              Expanded(child: _fieldLado()),
            ],
          ),
        _sp,
        _fieldNotas(),
        if(_showLinear)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: LinearProgressIndicator(),
          ),
        _sp,
        _btnsDeAccionDelForm(),
        if(widget.showFotos)
          _showFotos(sizeCurrent)
      ],
    );
  }

  ///
  Widget _frmPzaTableta() {

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _fieldOrigenDePieza(),
                  _sp,
                  _fieldDropSearchPieza(),
                  const SizedBox(height: 30),
                  _fieldPosicion(),
                  _sp,
                  _fieldLado(),
                ]
              )
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _fieldNotas(alto: 6),
                  if(widget.showFotos)
                    _showFotos(null)
                ],
              )
            ),
          ],
        ),
        _sp,
        _btnsDeAccionDelForm()
      ],
    );
  }

  ///
  Widget _showFotos(double? sizeCurrent) {

    double radio = 60;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      constraints: BoxConstraints(
        maxWidth: sizeCurrent ?? MediaQuery.of(context).size.width * 0.25,
        maxHeight: radio
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => widget.onEditFotos(null),
            child: const Tooltip(
              message: 'Gestionar Fotografías',
              child: CircleAvatar(
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            )
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              children: picktures.imageFileListOks.map((foto) {

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: radio+10,
                  height: radio,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[200],
                    border: Border.all(
                      color: Colors.grey,
                      width: 1
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      (foto['from'] == 'xfile') ? foto['path'] : GetUris.getUriFotoPzaBeforeCot(foto['filename']),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList()
            ),
          ),
          FutureBuilder(
            future: _checkFotosToSend(),
            builder: (_, AsyncSnapshot hasFotos) {
              if(hasFotos.hasData) {
                if(hasFotos.data) {
                  return StreamBuilder(
                    stream: _sendFotosWeb(),
                    builder: (_, __) => const SizedBox()
                  );
                }
              }
              return const SizedBox();
            }
          )
        ],
      ),
    );
  }

  ///
  Widget _btnsDeAccionDelForm() {

    return FocusTraversalOrder(
      order: const NumericFocusOrder(6),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(_bp == 'mediumHandset')
            Align(
              alignment: Alignment.centerRight,
                child: _btnActionFrm(
                label: 'TERMINAR', fnc: () async {
                  if(await _isValid()) {
                    widget.onTapTerminar(null);
                  }
                },
                bg: const Color.fromARGB(255, 76, 175, 80),
                icono: Chip(
                  labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  padding: const EdgeInsets.all(0),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.white,
                  label: Text(
                    '${context.watch<PzasToCotizarProv>().keysPiezas.length}',
                    textScaleFactor: 1,
                    style: _refCotz.globals.styleText(13, Colors.black, true)
                  ),
                )
              ),
            ),

          if(kIsWeb)
            ...[
              const SizedBox(width: 1),
              Align(
                alignment: Alignment.centerRight,
                  child: Center(
                    child: _btnActionFrm(
                      label: (_refCotz.keyPiezaEdit != -1) ? 'EDITAR Y LIMPIAR FORMULARIO' : 'AGREGAR A LA ORDEN',
                      fnc: () async {
                        if(await _isValid()) {
                          widget.onTapAddmore(null);
                          _cleanCampos();
                        }
                      },
                      icono: const Icon(Icons.add)
                    ),
                  )
              ),
              const SizedBox(width: 1)
            ]
          else
            Align(
              alignment: Alignment.centerRight,
                child: _btnActionFrm(
                label: (_refCotz.keyPiezaEdit != -1) ? 'EDITAR' : 'AGREGAR',
                fnc: () async {
                  if(await _isValid()) {
                    widget.onTapAddmore(null);
                    _cleanCampos();
                  }
                },
                icono: const Icon(Icons.add)
              )
            ),
        ],
      )
    );
  }

    ///
  Widget _btnActionFrm({
    required String label,
    required Widget icono,
    required Function fnc,
    Color bg = Colors.green
  }) {

    return ElevatedButton.icon(
      onFocusChange: (hasFocus) {
        if(!hasFocus) {
          _focusCan.requestFocus();
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(bg)
      ),
      onPressed: () async => await fnc(),
      icon: icono,
      label: Text(
        label,
        textScaleFactor: 1,
        style: _refCotz.globals.styleText(15, Colors.white, true)
      )
    );
  }

  ///
  Widget _fieldOrigenDePieza() {

    if(_ctrOrigen.text.isEmpty) {
      _ctrOrigen.text = _refCotz.origenes.first;
    }

    return FocusTraversalOrder(
      order: const NumericFocusOrder(1),
      child: Focus(
        canRequestFocus: false,
        descendantsAreFocusable: true,
        child: DropdownButtonFormField<String>(
          value: _ctrOrigen.text,
          focusNode: _focusOri,
          onChanged: (String? nval) {
            setState((){ _ctrOrigen.text = nval ?? _refCotz.origenes.first; });
            _focusPza.requestFocus();
          },
          decoration: InputDecoration(
            label: getLabel(label: '*Origen:'),
            labelStyle: styleLabel(),
            border: _bordeFrmInput(),
            enabledBorder: _bordeFrmInput(),
            filled: true,
            fillColor: Colors.white
          ),
          items: _refCotz.origenes.map((origen) {

            return DropdownMenuItem<String>(
              value: origen,
              child: Text(
                origen,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: 1
              ),
            );
          }).toList()
        ),
      )
    );
  }

  ///
  Widget _fieldDropSearchPieza() {

    return FocusTraversalOrder(
      order: const NumericFocusOrder(2),
      child: TypeAheadFormField(
        suggestionsBoxController: _ctrSug,
        validator: (String? val) {
          if(val != null) {
            if(val.length > 2) {
              return null;
            }
          }
          return 'La pieza es Requerida';
        },
        textFieldConfiguration: TextFieldConfiguration(
          controller: _ctrPieza,
          focusNode: _focusPza,
          autofocus: false,
          autocorrect: true,
          onEditingComplete: () {
            if(_ctrSug.isOpened()) {
              if(suggPiezas.isEmpty) {
                _focusPos.requestFocus();
                return;
              }
              _setPzaSelected(suggPiezas.first);
              _ctrSug.close();
              _focusNot.requestFocus();
            }else{
              _focusPos.requestFocus();
            }
          },
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            label: getLabel(label: '*Nombre Pieza'),
            labelStyle: styleLabel(),
            hintText: 'Ej. Cofre, Salpicadero ...',
            hintStyle: getStyHint(),
            border: _bordeFrmInput(),
            enabledBorder: _bordeFrmInput(),
            filled: true,
            fillColor: Colors.white,
          )
        ),
        autoFlipDirection: true,
        minCharsForSuggestions: 1,
        hideOnEmpty: true,
        getImmediateSuggestions: false,
        suggestionsCallback: (String patron) async {

          RegExp exp = RegExp(r"(\d+)");
          Iterable<RegExpMatch> matches = exp.allMatches(patron);
          if(matches.isNotEmpty && matches.first.group(0) != null) {
            return await _findSugerenciasDePiezasReg(
              patron, key: int.parse(matches.first.group(0)!)
            );
          }else{
            return await _findSugerenciasDePiezasReg(patron);
          }
        },
        itemBuilder: (context, Map<String, dynamic> pza) {
          return _lstSugerenciasDePiezaReg(pza);
        },
        onSuggestionSelected: (Map<String, dynamic> pza){
          _setPzaSelected(pza);
          _focusNot.requestFocus();
        }
      )
    );
  }

  ///
  Widget _fieldPosicion() {

    if(_ctrPosi.text.isEmpty) {
      _ctrPosi.text = _refCotz.posic.first;
    }

    return FocusTraversalOrder(
      order: const NumericFocusOrder(3),
      child: DropdownButtonFormField<String>(
        value: _ctrPosi.text,
        focusNode: _focusPos,
        onChanged: (String? nval) {
          _ctrPosi.text = nval ?? _refCotz.posic.first;
          _focusLado.requestFocus();
        },
        decoration: InputDecoration(
          label: getLabel(label: '*Posición:'),
          labelStyle: styleLabel(),
          border: _bordeFrmInput(),
          enabledBorder: _bordeFrmInput(),
          filled: true,
          fillColor: Colors.white
        ),
        items: _refCotz.posic.map((posic) {
          return DropdownMenuItem<String>(
            value: posic,
            child: Text(
              posic,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1
            ),
          );
        }).toList()
      )
    );    
  }

  ///
  Widget _fieldLado() {

    if(_ctrLado.text.isEmpty) {
      _ctrLado.text = _refCotz.lugar.first;
    }

    return FocusTraversalOrder(
      order: const NumericFocusOrder(4),
      child: DropdownButtonFormField<String>(
        value: _ctrLado.text,
        focusNode: _focusLado,
        onChanged: (String? nval) {
          _ctrLado.text = nval ?? _refCotz.lugar.first;
          _focusNot.requestFocus();
        },
        decoration: InputDecoration(
          label: getLabel(label: '*Lado de la Pieza:'),
          labelStyle: styleLabel(),
          border: _bordeFrmInput(),
          enabledBorder: _bordeFrmInput(),
          filled: true,
          fillColor: Colors.white
        ),
        items: _refCotz.lugar.map((lado) {
            return DropdownMenuItem<String>(
              value: lado,
              child: Text(
                  lado,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: 1
                ),
              );
            }
          ).toList()
        )
    );
    
  }

  ///
  Widget _fieldNotas({int alto = 3}) {

    return FocusTraversalOrder(
      order: const NumericFocusOrder(5),
      child: TextFormField(
        controller: _ctrNotas,
        focusNode: _focusNot,
        maxLines: alto,
        autocorrect: true,
        autovalidateMode: AutovalidateMode.always,
        validator: (String? val) {
          if(val != null) {
            if(val.isNotEmpty && val.length > 2) {
              if(val.length < 3) {
                return 'Se más específico por favor.';
              }
            }
            return null;
          }
          return 'Campo Opcional...';
        },
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onEditingComplete: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        decoration: InputDecoration(
          label: getLabel(label: 'Requerimientos:'),
          labelStyle: styleLabel(),
          hintText: 'Algunas notas adicionales que nos ayuden a encontrar la pieza que necesitas.',
          hintStyle: getStyHint(),
          border: _bordeFrmInput(),
          enabledBorder: _bordeFrmInput(),
          filled: true,
          fillColor: Colors.white,
        ),
      )
    );
  }

    ///
  Widget _lstSugerenciasDePiezaReg(Map<String, dynamic> pza) {

    return ListTile(
      focusNode: _lstFocusPzas,
      mouseCursor: SystemMouseCursors.click,
      dense: true,
      title: Text(
        pza['pieza'],
        textScaleFactor: 1,
        style: _refCotz.globals.styleText(18, Colors.green, true),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.1),
        child: Text(
          '${pza['key']}',
          textScaleFactor: 1,
          style: _refCotz.globals.styleText(14, Colors.grey, true),
        ),
      ),
      subtitle: Text(
        '${pza['posicion']}-${pza['lado']}',
        textScaleFactor: 1,
        style: _refCotz.globals.styleText(16, Colors.grey, false),
      ),
    );
  }

  ///
  OutlineInputBorder _bordeFrmInput() {

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Colors.blue,
        width: 1
      )
    );
  }

    ///
  TextStyle getStyHint() => TextStyle(color: Colors.grey[400]);

  ///
  Widget getLabel({required String label}) => Text(label, textScaleFactor: 1);

  ///
  TextStyle styleLabel() =>  const TextStyle(color: Colors.grey, fontSize: 22);
  
  
  // ---------------- CONTROLLER ------------------------------

  ///
  void _setPzaSelected(Map<String, dynamic> pza) {

    _ctrPieza.text= pza['pieza'];
    _ctrLado.text = pza['lado'];
    _ctrPosi.text = pza['posicion'];
    widget.onScrollMoveTo(null);
    suggPiezas = [];
    setState(() { });
  }

  ///
  Future<List<Map<String, dynamic>>> _findSugerenciasDePiezasReg(String pattern, {int? key}) async {

    suggPiezas = [];
    for (var i = 0; i < piezasRegs.length; i++) {
      if(key != null) {
        if(piezasRegs[i]['key'] == key) {
          suggPiezas.add(piezasRegs[i]);
        }
      }else{
        if(piezasRegs[i]['pieza'].toLowerCase().startsWith(pattern.toLowerCase())) {
          suggPiezas.add(piezasRegs[i]);
        }
      }
    }
    return suggPiezas;
  }

  ///
  Future<bool> _checkFotosToSend() async {

    List<int> hasFotosSinEnviar = [];
    for (var i = 0; i < picktures.imageFileListOks.length; i++) {
      if(!picktures.imageFileListOks[i]['sended']){
        hasFotosSinEnviar.add(1);
      }
    }
    return (hasFotosSinEnviar.isEmpty) ? false : true;
  }

  ///
  Stream<void> _sendFotosWeb() async* {

    String prefixWeb = 'nc-';
    MyHttp http = MyHttp();
    http.tokenServer = picktures.tokenServer;
    //String uri = GetUris.getUriBy('upload_img');
    
    picktures.imageFileListProcess.clear();
    picktures.imageFileList.clear();

    for (var i = 0; i < picktures.imageFileListOks.length; i++) {

      String filename = picktures.imageFileListOks[i]['filename'];
      if(!filename.startsWith(prefixWeb) && !filename.startsWith('share')) {
        filename = '$prefixWeb$filename';
        picktures.imageFileListOks[i]['filename'] = filename;
      }
      List<String> partes = filename.split('.');
      String ext = partes.last;
      picktures.imageFileListOks[i]['ext'] = ext;
      picktures.imageFileListOks[i]['from'] = 'server';

      picktures.imageFileListProcess.add(picktures.imageFileListOks[i]);
    }

    for (var i = 0; i < picktures.imageFileListProcess.length; i++) {

      if(!picktures.imageFileListProcess[i]['sended']) {

        // await http.upFile(
        //   uri,
        //   XFile(picktures.imageFileListProcess[i]['path']),
        //   metas: {
        //   'filename': picktures.imageFileListProcess[i]['filename'],
        //   'campo': picktures.idPiezaTmp,
        //   'ext': picktures.imageFileListProcess[i]['ext']
        // });

        // if(!http.result['abort']) {
        //   picktures.imageFileListProcess[i]['sended'] = true;
        //   if(!picktures.fotosFromServer.contains(picktures.imageFileListProcess[i]['filename'])) {
        //     picktures.fotosFromServer.add(picktures.imageFileListProcess[i]['filename']);
        //   }
        // }
      }
    }

  }

  ///
  Future<bool> _isValid() async  {

    if(widget.idOrden == 0) {

      await variosWidgets.dialog(
        cntx: context,
        tipo: 'entendido',
        icono: Icons.data_saver_off,
        colorIcon: Colors.orange,
        titulo: 'El sistema no detectó ningún Registro',
        textMain: 'Por favor, preciona el Boton de Cotizar en la pantalla principal para comenzar con una Solicitud'
      ).then((_) {
        if(!kIsWeb) {
          Navigator.of(context).pop();
        }
      });

      return false;
    }

    if(!_keyFrm.currentState!.validate()) {
      variosWidgets.message(
        context: context,
        bg: Colors.black, fg: Colors.orange[300]!,
        msg: 'ERRORES EN EL FORMULARIO'
      );
      return false;
    }

    setState(() { _showLinear = true; });

    if(_ctrNotas.text.length > 5) {
      String prenota = '';
      prenota = _ctrNotas.text.toLowerCase();
      prenota = '${ prenota[0].toUpperCase() }${ prenota.substring(1, prenota.length) }';
      _ctrNotas.text = prenota;
    }
    _ctrPieza.text = _ctrPieza.text.toUpperCase().trim();

    pzaCurrent.piezaOfOrdenCurrent['piezaName'] = _ctrPieza.text.toUpperCase().trim();
    pzaCurrent.piezaOfOrdenCurrent['origen'] = _ctrOrigen.text.toUpperCase().trim();
    pzaCurrent.piezaOfOrdenCurrent['lado'] = _ctrLado.text.toUpperCase().trim();
    pzaCurrent.piezaOfOrdenCurrent['posicion'] = _ctrPosi.text.toUpperCase().trim();
    pzaCurrent.piezaOfOrdenCurrent['obs'] = _ctrNotas.text;

    return true;
  }

  ///
  void _cleanCampos() {

    _ctrPieza.text = '';
    _ctrLado.text  = '';
    _ctrPosi.text  = '';
    _ctrNotas.text = '';
    _ctrOrigen.text= _refCotz.origenes.first;
    
    if(kIsWeb) {
      Future.delayed(const Duration(milliseconds: 300), (){
        _focusPza.requestFocus();
      });
    }
  }
}