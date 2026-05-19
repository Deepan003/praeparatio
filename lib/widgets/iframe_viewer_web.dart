// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

final _registered = <String>{};

Widget buildIframeViewer(String url) {
  final viewId = 'pdf-iframe-${url.hashCode.abs()}';
  if (!_registered.contains(viewId)) {
    _registered.add(viewId);
    ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
      return html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
    });
  }
  return HtmlElementView(viewType: viewId);
}
