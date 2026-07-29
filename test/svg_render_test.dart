import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('render assets/SVG to a montage', (tester) async {
    final dir = Directory('assets/SVG');
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.svg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (var i = 0; i < files.length; i++) {
      // ignore: avoid_print
      print('IDX $i = ${files[i].path.split(Platform.pathSeparator).last}');
    }

    final tiles = <Widget>[
      for (var i = 0; i < files.length; i++)
        Container(
          width: 150,
          height: 150,
          margin: const EdgeInsets.all(6),
          color: const Color(0xFFE7E3D2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: SvgPicture.string(files[i].readAsStringSync()),
              ),
              Text('$i',
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
    ];

    tester.view.physicalSize = const Size(960, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            color: const Color(0xFF555555),
            padding: const EdgeInsets.all(8),
            child: Wrap(children: tiles),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final bytes = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1.4);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data;
    });
    File('.figma/crop/svg_montage.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    // ignore: avoid_print
    print('SAVED svg_montage.png');
  });
}
