import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:provider/provider.dart';

import '../../../providers/pzas_to_cotizar_prov.dart';
import '../../../services/get_uris.dart';
import '../../../entity/orden_piezas.dart';
import '../../../widgets/get_fotos/singleton/picker_pictures.dart';

class TilePzaBeforeCot extends StatelessWidget {

  final OrdenPiezas pieza;
  final ValueChanged<Map<String, dynamic>> onAction;
  TilePzaBeforeCot({
    required this.pieza,
    required this.onAction,
    Key? key
  }) : super(key: key);

  final Globals globals = getSngOf<Globals>();
  final PickerPictures picktures = getSngOf<PickerPictures>();

  final Map<String, dynamic> action = {'onpress': '', 'keyPieza': 0};

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5
          )
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _acciones(),
          Expanded(
            child: InkWell(
              onTap: () {
                action['onpress'] = 'edit';
                action['keyPieza'] = pieza.key;
                onAction(action);
              },
              mouseCursor: SystemMouseCursors.click,
              child: _dataPieza(context)
            )
          ),
          Container(
            width: 1024 * 0.06,
            height: 768 * 0.06,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(
                width: 1,
                color: Colors.grey
              )
            ),
            child: AspectRatio(
              aspectRatio: 1024/768,
              child: (pieza.fotos.isEmpty)
              ? const Center(
                  child: Icon(Icons.no_photography_outlined, color: Colors.grey)
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/images/no-logo.png'),
                    image: NetworkImage(GetUris.getUriFotoPzaBeforeCot(pieza.fotos.first)),
                    fit: BoxFit.cover
                  )
                )
            )
          ),
        ],
      ),
    );
  }

  ///
  Widget _dataPieza(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                pieza.piezaName,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: 1,
                style: globals.styleText(17, Colors.black, true, sw: 1.1),
              )
            )
          ]
        ),
        const SizedBox(height: 3),
        Text(
          '${pieza.posicion} ${pieza.lado}',
          textScaleFactor: 1,
          style: globals.styleText(14, Colors.grey, false),
        )
      ],
    );
  }

  ///
  Widget _acciones() {

    return Selector<PzasToCotizarProv, List<Map<String, dynamic>>>(
      selector: (_, provi) => provi.pzasToSend,
      builder: (_, pzaToSendProv, __) {
        var pzaToSend = pzaToSendProv.where((element) => element['key'] == pieza.key);
        if(pzaToSend.isEmpty) {
          pzaToSend = [{'saved': false}];
        }

        return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _fncPiezas(
                tip: 'Editar Pieza',
                icono: Icons.edit,
                colorIcon: (pzaToSend.first['saved']) ? Colors.blue : Colors.grey,
                active: pzaToSend.first['saved'],
                fnc: () {
                  action['onpress'] = 'edit';
                  action['keyPieza'] = pieza.key;
                  onAction(action);
                }
              ),
              const SizedBox(width: 10),
              _fncPiezas(
                tip: 'Eliminar Pieza',
                icono: Icons.close,
                colorIcon: (pzaToSend.first['saved']) ? Colors.red : Colors.grey,
                active: pzaToSend.first['saved'],
                fnc: () {
                  action['onpress'] = 'del';
                  action['keyPieza'] = pieza.key;
                  onAction(action);
                }
              ),
              const SizedBox(width: 10),
            ],
          );
      },
    );
  }

  ///
  Widget _fncPiezas({
    required String tip,
    required IconData icono,
    required Function fnc,
    required bool active,
    Color colorIcon = Colors.blue,
  }) {

    return AbsorbPointer(
      absorbing: !active,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => fnc(),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: colorIcon,
            child: Tooltip(
              message: tip,
              child: Icon(icono, color:Colors.grey[100], size: 18),
            )
          ),
        )
      ),
    );
  }

}