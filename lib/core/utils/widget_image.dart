import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Paints [widget] in an off-screen overlay entry (so it inherits the app theme and fonts) and returns it as PNG bytes.
Future<Uint8List> renderWidgetToPng(
  BuildContext context,
  Widget widget, {
  double pixelRatio = 3,
}) async {
  final key = GlobalKey();
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -10000,
      top: 0,
      child: RepaintBoundary(key: key, child: widget),
    ),
  );

  Overlay.of(context, rootOverlay: true).insert(entry);
  try {
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  } finally {
    entry.remove();
  }
}
