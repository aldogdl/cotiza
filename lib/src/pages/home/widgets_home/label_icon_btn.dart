import 'package:flutter/material.dart';

import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

import '../data_shared/ds_repo.dart';

class LabelIconBtn extends StatelessWidget {

  final String label;
  final IconData icono;
  final Color? fg;
  final Color? colorIcon;

  LabelIconBtn({
    Key? key,
    required this.label,
    required this.icono,
    this.fg,
    this.colorIcon
  }) : super(key: key);

  final DsRepo dsRepo = getSngOf<DsRepo>();
  final Globals globals = getSngOf<Globals>();
  
  @override
  Widget build(BuildContext context) => _labelIconBtn();

  ///
  Widget _labelIconBtn() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icono, color: (colorIcon == null) ? Colors.grey : colorIcon, size: 20),
        const SizedBox(width: 5),
        SizedBox(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: 1,
            style: globals.styleText(14, (fg == null) ? Colors.white : fg!, false, sw: 1.1)
          ),
        ),
        if(label == 'Cotizar' && dsRepo.fromIdRepo == 'pendientes')
          ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.red
              ),
              child: Center(
                child: Text(
                  '${dsRepo.idRepoMainSelectCurrent}',
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: 1,
                  style: globals.styleText(12, Colors.white, true),
                ),
              ),
            )
          ]
      ],
    );
  }

}