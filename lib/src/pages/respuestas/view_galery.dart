import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:autoparnet_cotiza/vars/scroll_config.dart';

import '../../services/get_uris.dart';

class ViewGalery extends StatefulWidget {

  final List<String> fotos;
  final double maxWidth;
  final int idRepoMain;
  final int? idInfo;
  
  const ViewGalery({
    Key? key,
    required this.fotos,
    required this.maxWidth,
    required this.idRepoMain,
    this.idInfo
  }) : super(key: key);

  @override
  State<ViewGalery> createState() => _ViewGaleryState();
}

class _ViewGaleryState extends State<ViewGalery> {

  final PageController _pageCtr = PageController();

  @override
  void dispose() {
    _pageCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: _galeriaDeFotos(),
          ),
        ),
        Positioned(
          bottom: 10,
          width: widget.maxWidth,
          child: _manejadores() 
        )
      ],
    );
  }

  ///
  Widget _galeriaDeFotos() {

    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      itemCount: widget.fotos.length,
      builder: (_, int index) {
  
        String fotto = '';
        if(widget.idInfo != null) {
          fotto = GetUris.getUriFtoRespuesta(widget.idRepoMain, widget.idInfo!, widget.fotos[index]);
        }else{
          fotto = GetUris.getUriFotoPzaBeforeCot(widget.fotos[index]);
        }
  
        return PhotoViewGalleryPageOptions(
          basePosition: Alignment.center,
          imageProvider: NetworkImage(fotto),
          initialScale: PhotoViewComputedScale.covered,
          heroAttributes: PhotoViewHeroAttributes(tag: widget.fotos[index]),
        );
      },
      loadingBuilder: (context, event) => Center(
        child: SizedBox(
          width: 20.0, height: 20.0,
          child: CircularProgressIndicator(
            value: event == null
              ? 0
              : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
          ),
        ),
      ),
      backgroundDecoration: const BoxDecoration(
        color: Colors.black
      ),
      pageController: _pageCtr,
    );
  }

  ///
  Widget _manejadores() {

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _pageCtr.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
          icon: const CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white,
            child: Center(
              child: Icon(Icons.arrow_back, color: Colors.black, size: 18),
            ),
          )
        ),
        const SizedBox(width: 20),
        CircleAvatar(
          child: Text(
            '${widget.fotos.length}',
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: () =>_pageCtr.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
          icon: const CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white,
            child: Center(
              child: Icon(Icons.arrow_forward, color: Colors.black, size: 18),
            ),
          )
        )
      ],
    );
  }

}