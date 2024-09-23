import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starxpand/models/starxpand_document_display.dart';
import 'package:starxpand/starxpand.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<StarXpandPrinter>? printers;

  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List> getImageFromAsset(String assetPath) async {
    ByteData byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _find() async {
    var ps = await StarXpand.findPrinters(
        callback: (payload) => print('printer: $payload'));
    setState(() {
      printers = ps;
    });
  }

  _openDrawer(StarXpandPrinter printer) {
    StarXpand.openDrawer(printer);
  }

  _startInputListener(StarXpandPrinter printer) {
    StarXpand.startInputListener(
        printer, (p) => print('_startInputListener: ${p.inputString}'));
  }

  _print(StarXpandPrinter printer) async {
    var doc = StarXpandDocument();
    var printDoc = StarXpandDocumentPrint();

    printDoc.style(
        internationalCharacter: StarXpandStyleInternationalCharacter.usa,
        characterSpace: 0.0,
        alignment: StarXpandStyleAlignment.center);

    Uint8List imageData = await getImageFromAsset('assets/jihanlogo.jpg');
    printDoc.actionPrintImage(imageData, 260);
    printDoc.actionFeed(1);
    printDoc.add(StarXpandDocumentPrint()
      ..style(
        magnification: StarXpandStyleMagnification(2, 1),
        alignment: StarXpandStyleAlignment.center,
        bold: true,
      )
      ..actionPrintText("CHICKEN WHOLE"));

    Uint8List halalLogo = await getImageFromAsset('assets/halal_logo.jpg');

    printDoc.addPageMode(StarXpandPageMode()
      ..actionPrintRuledLine(
        xStart: 0,
        yStart: 1,
        xEnd: 58,
        yEnd: 1,
        thickness: 0.3,
      )
      ..actionPrintRuledLine(
        xStart: 0,
        yStart: 6,
        xEnd: 58,
        yEnd: 6,
        thickness: 0.3,
      )
      ..actionPrintRuledLine(
        xStart: 18,
        yStart: 5,
        xEnd: 18,
        yEnd: 12,
        thickness: 0.3,
      )
      ..actionPrintRuledLine(
        xStart: 36,
        yStart: 5,
        xEnd: 36,
        yEnd: 12,
        thickness: 0.3,
      )
      ..style(horizontalPositionTo: 2, verticalPositionTo: 2)
      ..actionPrintText("NET WT.")
      ..style(horizontalPositionTo: 20, verticalPositionTo: 2)
      ..actionPrintText("UNIT PRICE")
      ..style(horizontalPositionTo: 38, verticalPositionTo: 2, bold: true)
      ..actionPrintText("TOTAL PRICE")
      ..actionPrintImage(halalLogo, 8, 15, 70)
      ..style(
        horizontalPositionTo: 33,
        verticalPositionTo: 16,
        bold: true,
      )
      ..actionPrintText("PACK DATE")
      ..style(horizontalPositionTo: 33, verticalPositionTo: 20)
      ..actionPrintText("11/11/2011"));

    printDoc.actionCut(StarXpandCutType.full);

    doc.addPrint(printDoc);
    StarXpand.printDocument(printer, doc);
  }

  int displayCounterText = 0;

  /**
   * Can also be added to a normal printDocument via
   * doc.addDisplay(StarXpandDocumentDisplay display)
   */
  void _updateDisplayText(StarXpandPrinter printer) {
    var displayDoc = StarXpandDocumentDisplay()
      ..actionClearAll()
      ..actionClearLine()
      ..actionShowText("StarXpand\n")
      ..actionClearLine()
      ..actionShowText("Updated ${++displayCounterText} times");

    StarXpand.updateDisplay(printer, displayDoc);
  }

  void _getStatus(StarXpandPrinter printer) async {
    try {
      var status = await StarXpand.getStatus(printer);
      print("Got status ${status.toString()}");
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('StarXpand SDK - Example app'),
        ),
        body: Column(children: [
          TextButton(
              child: Text('Search for devices'), onPressed: () => _find()),
          if (printers != null)
            for (var p in printers!)
              ListTile(
                  onTap: () => _print(p),
                  title: Text(p.model.label + "(${p.interface.name})"),
                  subtitle: Text(p.identifier),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                          onPressed: () => _print(p), child: Text("Print")),
                      Container(width: 4),
                      OutlinedButton(
                          onPressed: () => _openDrawer(p),
                          child: Text("Open drawer")),
                      Container(width: 4),
                      OutlinedButton(
                          onPressed: () => _updateDisplayText(p),
                          child: Text("Update display")),
                      Container(width: 4),
                      OutlinedButton(
                          onPressed: () => _getStatus(p),
                          child: Text("Get Status")),
                    ],
                  ))
        ]),
      ),
    );
  }
}
