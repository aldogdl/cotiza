import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'auto_controller.dart';
import '../../services/get_uris.dart';

class AutoUI extends StatelessWidget {

  final BuildContext parentContext;
  final AutoControllerState ctr;
  const AutoUI(this.parentContext, this.ctr, {Key? key}) : super(key: key);

  AutoController get params => ctr.widget;

  @override
  Widget build(BuildContext context) {
    
    double alto = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: (){
        switch (ctr.tipoLista) {
          case 'anios':
            ctr.backToModelos();
            break;
          case 'modelos':
            ctr.backToMarcas();
            break;
        }

        if(ctr.tipoLista == 'marcas') {
          return Future.value(true);
        }else{
          return Future.value(false);
        }
      },
      child: Column(
        children: [
          if(!kIsWeb)
            _viewRepoSelect(),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: (kIsWeb) ? alto * 0.98 : alto,
              padding: const EdgeInsets.all(5),
              constraints: BoxConstraints(
                maxWidth: (ctr.globals.isMobileDevice) ? MediaQuery.of(context).size.width : ctr.widthMin,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xcc5FB131),
                    Colors.grey[100]!,
                    Colors.white
                  ],
                  stops: [
                    0.2,
                    MediaQuery.of(context).size.height * 0.5,
                    MediaQuery.of(context).size.height * 0.5,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                )
              ),
              child: _body()
            ),
          )
        ],
      ),
    );
  }

  Widget _body() {

    return Column(
      children: [
        if(kIsWeb)
          _viewRepoSelect(),
        _barrNavegation(),
        _inputBusk(),
        if(ctr.tipoLista == 'marcas')
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.greenAccent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            ),
            child: _checkNacionalidad()
          ),
        Expanded(
          child: _lstItemsBuilder()
        )
      ],
    );
  }

  ///
  Widget _lstItemsBuilder() {

    late Widget lista;
    switch (ctr.tipoLista) {
      case 'marcas':
        lista = ListView.builder(
          shrinkWrap: true,
          controller: ctr.ctrScroll,
          itemCount: ctr.itemsFiltrados.length,
          itemBuilder: (_, int index) => _tileElementByMarcas(index)
        );
        break;
      case 'modelos':
        lista = ListView.builder(
          shrinkWrap: true,
          controller: ctr.ctrScroll,
          itemCount: ctr.itemsFiltrados.length,
          itemBuilder: (_, int index) => _tileElementByModelos(index)
        );
        break;
      case 'anios':
        lista = ListView.builder(
          shrinkWrap: true,
          controller: ctr.ctrScroll,
          itemCount: ctr.itemsFiltrados.length,
          itemBuilder: (_, int index) => _tileElementByAnios(index)
        );
        break;
      case 'sending':
        lista = imgSending();
        break;
      case 'errFromServer':
        lista = _showMsgErr();
        break;
      default:
        lista = _cargador();
    }

    return Container(
      decoration: BoxDecoration(
        color: ctr.bgLstAuto,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10)
        ),
      ),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(5),
      child: SizedBox.expand(
        child: lista
      ),
    );    
  }
  
  ///
  Widget _viewRepoSelect() {

    return Container(
      height:  768 * 0.1,
      color: Colors.grey[900],
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 1027 * 0.07,
            height: 768 * 0.07,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5)
            ),
            child: (ctr.logoSelect == '0')
            ? null
            : CachedNetworkImage(
              imageUrl: '${GetUris.getUriLogoMarcas()}/${ctr.logoSelect}',
            )
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: ctr.modeloSelect,
                      builder: (_, String mod, __) {
                        return Text(
                          mod,
                          textScaleFactor: 1,
                          style: ctr.globals.styleText(
                            16,
                            (mod == 'MODELO') ? Colors.grey : Colors.grey[100]!,
                            true
                          )
                        );
                      }
                    ),
                    Text(
                      ' - ${ctr.anio}',
                      textScaleFactor: 1,
                      style: ctr.globals.styleText(16, Colors.grey[100]!, true)
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      ctr.getMarcaCurrent(),
                      textScaleFactor: 1,
                      style: ctr.globals.styleText(
                        12,
                        (ctr.idMarcaSelect == -1) ? Colors.grey : Colors.grey[100]!,
                        true
                      )
                    ),
                    Text(
                      ' - ${ctr.getNacionalidadCurrent()}',
                      textScaleFactor: 1,
                      style: ctr.globals.styleText(12, Colors.white, true)
                    ),
                  ],
                ),
                Text(
                  'Selecciona el Auto correspondiente',
                  textScaleFactor: 1,
                  style: ctr.globals.styleText(11, Colors.grey, true)
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  ///
  Widget _barrNavegation() {

    return Row(
      children: [
        if(ctr.idMarcaSelect != -1)
          _btnNav(
            label: 'Marcas',
            icono: Icons.arrow_forward_ios,
            sizeIcon: 12,
            colorIcon: Colors.grey,
            fnc: () => ctr.backToMarcas()
          ),
        if(ctr.idModelosSelect != -1)
          _btnNav(
            label: 'Modelos',
            icono: Icons.arrow_forward_ios,
            sizeIcon: 12,
            colorIcon: Colors.grey,
            fnc: () => ctr.backToModelos()
          ),
        const Spacer(),
        if(ctr.showBtnClose)
          _btnNav(
            label: 'CERRAR',
            icono: Icons.close,
            colorIcon: Colors.black,
            fnc: () => ctr.close()
          )
      ]
    );
  }

  ///
  Widget _btnNav({
    required String label,
    required IconData icono, 
    required Function fnc,
    double sizeIcon = 24,
    Color colorIcon = Colors.red,
  }) {

    return TextButton(
      onPressed: () => fnc(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            textScaleFactor: 1,
            style: ctr.globals.styleText(13, const Color(0xFF000000), true),
          ),
          const SizedBox(width: 10),
          Icon(icono, color: colorIcon, size: sizeIcon)
        ]
      )
    );
  }

  ///
  Widget _checkNacionalidad() {

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: ctr.isNac,
      checkColor: Colors.black,
      activeColor: Colors.white.withOpacity(0.7),
      onChanged: (newVal) => ctr.setNacionalidad(newVal),
      title: Text(
        'El AUTO requerido es ${ (ctr.isNac) ? 'NACIONAL' : 'IMPORTADO' }',
        textScaleFactor: 1,
        textAlign: TextAlign.left,
        style: ctr.globals.styleText(14, Colors.black, true, sw: 1.1),
      )
    );
  }

  ///
  Widget _inputBusk() {

    return TextField(
      controller: ctr.ctrBsk,
      focusNode: ctr.focusBsk,
      autofocus: true,
      obscureText: false,
      onChanged: (String busk) => ctr.buscarItem(busk),
      keyboardType: (ctr.keyboardCurrent == 'txt') ? TextInputType.text : TextInputType.number,
      decoration: InputDecoration(
        border: borderStyle(),
        enabledBorder: borderStyle(),
        filled: true,
        fillColor: Colors.green[50]!,
        label: Text(
          'Buscador...',
          textScaleFactor: 1,
          style: ctr.globals.styleText(15, Colors.black, true)
        ),
        prefixIcon: const Icon(Icons.directions_car, color: Colors.grey),
        suffixIcon: const Icon(Icons.search)
      ),
    );
  }
  
  ///
  Widget _tileElementByMarcas(int index) {

    String logo = 'no-logo.png';
    if(ctr.itemsFiltrados[index].logo != '0') {
      logo = ctr.itemsFiltrados[index].logo;
    }
    
    return TextButton(
      onPressed: () => ctr.seleccionarMarca(index),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        mouseCursor: MaterialStateProperty.all(
          SystemMouseCursors.click
        )
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5)
          ),
          width: 40, height: 40,
          child: CachedNetworkImage(
            imageUrl: '${GetUris.getUriLogoMarcas()}/$logo',
          )
        ),
        trailing: const Icon(Icons.arrow_forward_ios_outlined, size: 15),
        title: Text(
          ctr.itemsFiltrados[index].marca,
          textScaleFactor: 1,
          style: ctr.globals.styleText(16, Colors.black, true)
        ),
      ),
    );
  }

  ///
  Widget _tileElementByModelos(int index) {

    return _tileItemDynamic(
      fnc: () => ctr.seleccionarModelo(index),
      label: ctr.itemsFiltrados[index].modelo,
      index: index
    );
  }

  ///
  Widget _tileElementByAnios(int index) {

    return _tileItemDynamic(
      fnc: () => ctr.seleccionarAnio(index),
      label: '${ctr.itemsFiltrados[index]}',
      index: index
    );
  }

  ///
  Widget _tileItemDynamic({
    required Function fnc,
    required String label,
    required int index,
  }) {

    return TextButton(
      onPressed: () => fnc(),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: MaterialStateProperty.all(EdgeInsets.zero)
      ),
      child: ListTile(
        dense: true,
        trailing: const Icon(Icons.arrow_forward_ios_outlined, size: 15),
        title: Text(
          label,
          textScaleFactor: 1,
          style: ctr.globals.styleText(16, Colors.black, true)
        ),
      ),
    );
  }

  ///
  Widget _cargador() {

    return Column(
      mainAxisSize: (ctr.globals.isMobileDevice) ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(
          width: 40, height: 40,
          child: CircularProgressIndicator(),
        ),
        SizedBox(height: 10),
        Text(
          'Cargando Items',
          textScaleFactor: 1
        )
      ]
    );
  }

  ///
  Widget _showMsgErr() {

    return Column(
      mainAxisSize: (ctr.globals.isMobileDevice) ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline_outlined,
          size: 50,
          color: Colors.red,
        ),
        const SizedBox(height: 10),
        const Text(
          'Ocurrio un Error Inesperado, por favor, inténtalo nuevamente',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => ctr.buildOrdenToServer(),
          child: const Text(
            'Intentar Nuevamente',
            textScaleFactor: 1
          ),
        )
      ]
    );
  }

  ///
  Widget imgSending() {
    
    double altoImg = 320;
    if(kIsWeb) {
      altoImg = 260;
    }

    return SizedBox(
      height: MediaQuery.of(parentContext).size.height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            ctr.msgLoad,
            textScaleFactor: 1,
          ),
          const LinearProgressIndicator(),
          const SizedBox(height: 10),
          SizedBox(
            child: SvgPicture.asset(
              'assets/svgs/navigator.svg',
              semanticsLabel: 'Enviando Datos',
              alignment: Alignment.topCenter,
              fit: BoxFit.contain,
              height: altoImg,
            ),
          ),
        ]
      )
    );
  }

  ///
  OutlineInputBorder borderStyle() {

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.green[50]!,
        width: 1
      )
    );
  }

}