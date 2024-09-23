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
        magnification: StarXpandStyleMagnification(1, 2),
        alignment: StarXpandStyleAlignment.center,
        bold: true,
      )
      ..actionPrintText("BEEF SHOULDER WITHOUT BONE"));

    Uint8List halalLogo = await getImageFromAsset('assets/halal_logo.jpg');

    double thickness = 0.3;
    double labelWidth = 58;
    double firstLineY = 0;
    double secondLineY = 4;
    double tableHeaderY = 1;
    double tableRowY = 6;

    printDoc.addPageMode(StarXpandPageMode()
      ..style(
        bold: false,
        magnification: StarXpandStyleMagnification(1, 1),
      )
      ..actionPrintRuledLine(
        xStart: 0,
        yStart: firstLineY,
        xEnd: labelWidth,
        yEnd: firstLineY,
        thickness: thickness,
      )
      ..actionPrintRuledLine(
        xStart: 0,
        yStart: secondLineY,
        xEnd: labelWidth,
        yEnd: secondLineY,
        thickness: thickness,
      )
      ..actionPrintRuledLine(
        xStart: 16,
        yStart: 0,
        xEnd: 16,
        yEnd: 11,
        thickness: thickness,
      )
      ..actionPrintRuledLine(
        xStart: 34,
        yStart: 0,
        xEnd: 34,
        yEnd: 11,
        thickness: thickness,
      )
      ..style(horizontalPositionTo: 4, verticalPositionTo: tableHeaderY)
      ..actionPrintText("NET WT.")
      ..style(horizontalPositionTo: 18, verticalPositionTo: tableHeaderY)
      ..actionPrintText("UNIT PRICE")
      ..style(
          horizontalPositionTo: 37,
          verticalPositionTo: tableHeaderY,
          bold: true)
      ..actionPrintText("TOTAL PRICE")
      ..style(
          horizontalPositionTo: 2.5, verticalPositionTo: tableRowY, bold: false)
      ..actionPrintText("60.00lbs")
      ..style(
          horizontalPositionTo: 18, verticalPositionTo: tableRowY, bold: false)
      ..actionPrintText("\$99.99/lbs")
      ..style(
        horizontalPositionTo: 36,
        verticalPositionTo: tableRowY,
        bold: true,
        magnification: StarXpandStyleMagnification(2, 1),
      )
      ..actionPrintText("\$99.99")
      ..actionPrintImage(halalLogo, 8, 10.5, 70)
      ..style(
        horizontalPositionTo: 33,
        verticalPositionTo: 12,
        bold: true,
        magnification: StarXpandStyleMagnification(1, 1),
      )
      ..actionPrintText("PACK DATE")
      ..style(
        horizontalPositionTo: 33,
        verticalPositionTo: 16,
        bold: false,
      )
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
