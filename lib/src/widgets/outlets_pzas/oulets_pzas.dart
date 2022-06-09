import 'package:flutter/material.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';
import 'package:autoparnet_cotiza/vars/scroll_config.dart';

class OutletsPzas extends StatelessWidget {

  final BoxConstraints constraints;
  OutletsPzas({
    required this.constraints,
    Key? key
  }) : super(key: key);

  final globals = getSngOf<Globals>();

  @override
  Widget build(BuildContext context) {

    double maxW = globals.getMaxWidht(constraints);
    double maxH = globals.getHeight(context);

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        width: (maxW <= globals.minW) ? globals.minW * 0.89 : maxW * 0.96,
        height: (maxH <= 650) ? 240 : maxH * 0.33,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ESCAPARATE OUTLET',
                  textScaleFactor: 1,
                  style: globals.styleText(12, Colors.green, true, sw: 1.1)
                ),
                InkWell(
                  onTap: () => globals.showOutlet.value = !globals.showOutlet.value,
                  child: const Icon(Icons.close, color: Colors.white, size: 20)
                )
              ]
            ), 
            // 1654564939560
            const SizedBox(height: 10),
            Expanded(
              child: ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: ListView.builder(
                  itemCount: 5,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (_, index) {
                    return _cardOutLet(index);
                  }
                )
              )
            )
          ]
        )
      )
    );
  }

  ///
  Widget _cardOutLet(int index) {

    return Container(
      margin: const EdgeInsets.only(right: 15),
      width: 140,
      height: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[100]
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1024/768,
            child: Container(
              color: Colors.grey,
              child: const Center(
                child: Text(
                  'FOTO',
                  textScaleFactor: 1
                )
              )
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  SizedBox(
                    child: Text(
                      'CASCO COMPLETO',
                      textScaleFactor: 1,
                      overflow: TextOverflow.ellipsis,
                      style: globals.styleText(12, Colors.black, true)
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    child: Text(
                      'GRAN UNIVERSAL 1995',
                      textScaleFactor: 1,
                      overflow: TextOverflow.ellipsis,
                      style: globals.styleText(11, Colors.blue, true)
                    ),
                  ),
                  SizedBox(
                    child: Text(
                      'Chevrolette - Importado',
                      textScaleFactor: 1,
                      overflow: TextOverflow.ellipsis,
                      style: globals.styleText(11, Colors.black, false)
                    ),
                  ),
                  const Spacer(),
                  const Divider(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Precio: ',
                        textScaleFactor: 1,
                        overflow: TextOverflow.ellipsis,
                        style: globals.styleText(10, Colors.green, false)
                      ),
                      Text(
                        '\$1,236.00',
                        textScaleFactor: 1,
                        overflow: TextOverflow.ellipsis,
                        style: globals.styleText(15, Colors.red, true)
                      ),
                    ]
                  )
                ],
              )
            )
          )
        ]
      ),
    );
  }

}