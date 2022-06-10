import 'package:flutter/material.dart';

class SliceMain extends StatelessWidget {

  final double maxW;
  final Map<String, dynamic> data;
  final int itemCount;
  final int index;
  final PageController pageCtr;

  const SliceMain({
    Key? key,
    required this.maxW,
    required this.data,
    required this.itemCount,
    required this.index,
    required this.pageCtr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector( onTap: () => _cambiaPage(), child: _body(context));
  }

  ///
  Widget _body(BuildContext context) {

    return Container(
      width: maxW,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF4B4B4B),
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          // Lado azul del Icono
          Container(
            width: maxW * 0.22,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.none,
                repeat: ImageRepeat.noRepeat
              ),
              color: Color.fromARGB(255, 13, 102, 236),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _getMsg(data['poster'])
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    data['titulo'],
                    textScaleFactor: 1,
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 21,
                      fontWeight: FontWeight.w200
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for(var m=0; m < itemCount; m++)
                          _bolita(m)
                      ],
                    )
                  ),
                  Text(
                    data['parrafo'],
                    textScaleFactor: 1,
                    style: const TextStyle(
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

  ///
  Widget _getMsg(Map<String, dynamic> data) {

    return RotatedBox(
      quarterTurns: -1,
      child: Row(
        children: [
          const SizedBox(width: 5),
          RotatedBox(
            quarterTurns: 1,
            child: Icon(data['ico'], size: 35, color: const Color.fromARGB(255, 57, 100, 240)),
          ),
          const SizedBox(width: 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _txt(data['label1'], 17),
              _txt(data['label2'], 13.5),
            ],
          )
        ],
      )
    );
  }

  ///
  Widget _txt(String label, double sf) {

    return Text(
      label,
      textScaleFactor: 1,
      textAlign: TextAlign.center,
      style: _style(sf) 
    );
  }
  
  ///
  TextStyle _style(double sf) {

    return TextStyle(
      fontSize: sf,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      letterSpacing: 1.5
    );
  }

  ///
  Widget _bolita(int indexCurrent) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Icon(
        Icons.circle, size: 15,
        color: (indexCurrent == index) ? const Color(0xFFbfca3c) : const Color(0xFF8aa5ae),
      ),
    );
  }

  ///
  void _cambiaPage() {

    if((index+1) != itemCount) {

      pageCtr.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn
      );
    }else{
      pageCtr.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn
      );
    }
  }

}