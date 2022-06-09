import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CotizaAqui extends StatelessWidget {

  final double maxW;
  const CotizaAqui({
    Key? key,
    required this.maxW
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: maxW,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 75, 75, 75),
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          // Lado azul del Icono
          Container(
            width: maxW * 0.22,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 13, 102, 236),
              borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
              child: SvgPicture.asset(
                'assets/svgs/men_app.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: const [
                  Text(
                    'Nunca fué tan fácil COTIZAR refacciones',
                    textScaleFactor: 1,
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 21,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.green, height: 20)),
                  Text(
                    'Contamos con una red de cientos de proveedores lo cual te '
                    'GARANTIZA, encontrar las autopartes que necesitas',
                    textScaleFactor: 1,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.normal
                    ),
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}