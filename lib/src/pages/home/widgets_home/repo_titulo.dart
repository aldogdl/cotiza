import 'package:flutter/material.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

class RepoTitulo extends StatelessWidget {

  final String titulo;
  final ValueChanged<int> onTap;
  RepoTitulo({
    Key? key,
    required this.titulo,
    required this.onTap,
  }) : super(key: key);

  final globals = getSngOf<Globals>();

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xcc5FB131).withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => onTap(-1),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: Text(
              'REGRESAR',
              textScaleFactor: 1,
              style: globals.styleText(13, Colors.green, false),
            )
          ),
          const SizedBox(width: 20),
          Text(
            titulo,
            textScaleFactor: 1,
            style: globals.styleText(15, Colors.white, true),
          )
        ],
      ),
    );
  }
}