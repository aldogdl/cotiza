import 'dart:math';

import 'package:flutter/material.dart';
import 'circle_progress_entity.dart';

class CircleProgress extends StatefulWidget {

  final CircleProgressEntity valores;
  final bool isBasic;
  const CircleProgress({
    required this.valores,
    this.isBasic = false,
    Key? key
  }) : super(key: key);

  @override
  State<CircleProgress> createState() => _CircleProgressState();
}

class _CircleProgressState extends State<CircleProgress> {

  int progressInfinity = 0;
  double radio = 0.8;
  double rd = 0;
  Future? contador;

  @override
  void initState() {
    _automatizarConteoCircularProgress();
    super.initState();
  }

  @override
  void dispose() {
    contador = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Size mq = MediaQuery.of(context).size;
    rd = mq.width * radio;
    if(rd >= 250) {
      rd = 250;
    } 
    return Container(
      width: rd,
      height: rd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rd),
        border: Border.all(
          color: Colors.black,
          width: 1
        )
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox.expand(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 1,
            )
          ),
          Padding(
            padding: EdgeInsets.all(mq.width * 0.01),
            child: SizedBox.expand(
              child: CustomPaint(
                painter: AnguloProgress(
                  fill: progressInfinity,
                ),
              )
            ),
          ),
          _numberProgress()
        ],
      ),
    );
  }

  ///
  Widget _numberProgress() {
    
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if(!widget.isBasic)
            ...[
              Text(
                widget.valores.taskMain,
                textScaleFactor: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: rd * 0.06,
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1
                )
              ),
              const SizedBox(height: 15),
            ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  _conteoAutomatico(),
                  if(!widget.isBasic)
                    ...[
                      const SizedBox(width: 10),
                      Text(
                        widget.valores.progreso,
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: rd * 0.21,
                          color: Colors.white,
                          letterSpacing: -5,
                          height: 1
                        )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '/ ${widget.valores.totalData}',
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: rd * 0.05,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey[400],
                          height: 1
                        )
                      ),
                    ]
                ],
              ),
            ),
          ),
          Text(
            widget.valores.elemento,
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rd * 0.05,
              color: Colors.grey,
            )
          ),
        ]
      )
    );
  }

  ///
  Widget _conteoAutomatico() {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$progressInfinity',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: rd * 0.1,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 3,
            height: 1
          )
        ),
        Text(
          'VELOCIDAD',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: rd * 0.025,
            fontWeight: FontWeight.w300,
            color: Colors.grey[400],
            height: 1
          )
        )
      ],
    );
  }

  ///
  void _automatizarConteoCircularProgress() {

    if(mounted) {
      setState((){  });
    }

    if(progressInfinity < 100) {
      contador = Future.delayed(const Duration(milliseconds: 300), (){
        progressInfinity = progressInfinity + 3;
        _automatizarConteoCircularProgress();
      });
    }else{
      progressInfinity = 0;
      _automatizarConteoCircularProgress();
    }
  }

}


class AnguloProgress extends CustomPainter {

  final int fill;

  AnguloProgress({
    required this.fill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    final center = Offset(size.width / 2, size.height / 2);
    final radiusLine = min(size.width / 2.5, size.height / 2.5);
    final radiusLineOver = min(size.width / 2.6, size.height / 2.6);
    final radius = min(size.width / 2, size.height / 2);
    double arcAngle = (2 * pi) * (fill / 100);
    
    double arcProgress = (2 * pi) * (30 / 100);

    Paint paintLine = Paint()
    ..color = Colors.black
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

    Paint paint = Paint()
    ..color = Colors.grey[800]!
    ..strokeWidth = 2
    ..style = PaintingStyle.fill;

    Paint paintprogress = Paint()
    ..color = Colors.grey[900]!
    ..strokeWidth = 7
    ..style = PaintingStyle.fill;

    Paint paintFill = Paint()
    ..color = Colors.blue
    ..strokeWidth = 7
    ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi/3,
      arcProgress,
      false,
      paintprogress
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi/1.5,
      arcProgress,
      false,
      paintprogress
    );
    canvas.drawCircle(center, radiusLine, paint);
    canvas.drawCircle(center, radiusLineOver, paintLine);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radiusLine),
      -pi/2,
      arcAngle,
      false,
      paintFill
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}