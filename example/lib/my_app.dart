import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/get_utils.dart';

import 'package:starxpand/models/starxpand_document_display.dart';
import 'package:starxpand/starxpand.dart';

class _MyAppState extends State<MyApp> {
  List<StarXpandPrinter>? printers;
  String log = "";

  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List> getImageFromAsset(String assetPath) async {
    ByteData byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> findPrinters() async {
    if (kReleaseMode) {
      var ps = await StarXpand.findPrinters(
        callback: (payload) {
          setState(() {
            print('printer: $payload');

            log = 'printer: $payload';
          });
        },
      );
      log = 'callback printers: ${ps.map((el) => el.toString()).join(",")}';
      setState(() {
        printers = ps;
      });
    } else {
      //DEBUG
      var data = [
        {
          "model": 'smT300',
          "identifier": 'identifier',
          "interface": 'bluetooth',
        },
        {
          "model": 'smT300i',
          "identifier": 'identifier',
          "interface": 'bluetooth',
        },
      ];

      setState(() {
        printers =
            data
                .map(
                  (e) => StarXpandPrinter.fromMap(Map<String, dynamic>.from(e)),
                )
                .toList();

        log = 'printer: $printers';
      });
    }
  }

  handleOpenDrawer(StarXpandPrinter printer) {
    StarXpand.openDrawer(printer);
  }

  _startInputListener(StarXpandPrinter printer) {
    StarXpand.startInputListener(
      printer,
      (p) => print('_startInputListener: ${p.inputString}'),
    );
  }

  handlePrint1(StarXpandPrinter printer) async {
    var doc = StarXpandDocument();
    var printDoc = StarXpandDocumentPrint();

    printDoc.style(
      internationalCharacter: StarXpandStyleInternationalCharacter.usa,
      characterSpace: 0.0,
      alignment: StarXpandStyleAlignment.center,
    );

    // image 1
    http.Response response = await http.get(
      Uri.parse(
        'https://cdn-staging.123tix.com.au/templates/123tix/assets/img/logo@2x.png',
      ),
    );
    printDoc.actionPrintImage(response.bodyBytes, 350);

    // image 2
    Uint8List imageData = await getImageFromAsset('assets/logo.png');
    printDoc.actionPrintImage(imageData, 260);

    printDoc.actionFeed(1);

    // document 1
    printDoc.add(
      StarXpandDocumentPrint()
        ..style(
          magnification: StarXpandStyleMagnification(1, 2),
          alignment: StarXpandStyleAlignment.left,
          bold: true,
        )
        ..actionPrintText("•••••••••••••••••\n")
        ..actionPrintText("BOLD LABEL\n")
        ..actionPrintText("•••••••••••••••••\n")
        ..actionPrintRuledLine(
          6,
          thickness: 2,
          lineStyle: StarXpandLineStyle.double,
        ),
    );

    // document 2
    printDoc.add(
      StarXpandDocumentPrint()
        ..style(
          magnification: StarXpandStyleMagnification(1, 2),
          alignment: StarXpandStyleAlignment.left,
          bold: true,
        )
        ..actionPrintText("•••••••••••••••••\n")
        ..actionPrintText("BOLD LABEL\n")
        ..actionPrintText("•••••••••••••••••\n")
        ..actionPrintRuledLine(
          6,
          thickness: 2,
          lineStyle: StarXpandLineStyle.double,
        ),
    );

    // QR
    printDoc.actionPrintQRCode(
      "https://123tix.au",
      model: StarXpandQRCodeModel.model2,
      level: StarXpandQRCodeLevel.q,
      cellSize: 8,
    );

    printDoc.actionCut(StarXpandCutType.full);

    doc.addPrint(printDoc);
    final result = await StarXpand.printDocument(printer, doc);
    setState(() {
      log += "\r\nprint result: $result";
    });
  }

  handlePrintGraphic(StarXpandPrinter printer) async {
    var doc = StarXpandDocument();
    var printDoc = StarXpandDocumentPrint();

    printDoc.style(
      internationalCharacter: StarXpandStyleInternationalCharacter.usa,
      characterSpace: 0.0,
      alignment: StarXpandStyleAlignment.center,
    );

    printDoc.actionPrintGraphic(
      "123TIX TICKET\n" +
          "<b>123 Star Road</b>\n" +
          "<u>City, State 12345</u>\n" +
          "••••••••••••\n" +
          "AAAAAAAA" +
          "------------\n",
    );

    printDoc.actionCut(StarXpandCutType.full);

    doc.addPrint(printDoc);
    StarXpand.printDocument(printer, doc);
  }

  // •••••••••••••••••••••••••••••••••••••••••••••••

  handlePrint2(StarXpandPrinter printer) async {
    var doc = StarXpandDocument();
    var printDoc = StarXpandDocumentPrint();

    printDoc.style(
      internationalCharacter: StarXpandStyleInternationalCharacter.usa,
      characterSpace: 0.0,
      alignment: StarXpandStyleAlignment.center,
    );

    // step1
    Uint8List imageData = await getImageFromAsset('assets/splash.jpg');
    printDoc.actionPrintImage(imageData, 260);

    // step2
    printDoc.actionFeed(1);
    printDoc.add(
      StarXpandDocumentPrint()
        ..style(
          magnification: StarXpandStyleMagnification(1, 2),
          alignment: StarXpandStyleAlignment.center,
          bold: true,
        )
        ..actionPrintText("BOLD LABEL"),
    );
    printDoc.actionCut(StarXpandCutType.full);

    // Uint8List halalLogo = await getImageFromAsset('assets/halal_logo.jpg');

    double thickness = 0.3;
    double labelWidth = 58;
    double firstLineY = 0;
    double secondLineY = 4;
    double tableHeaderY = 1;
    double tableRowY = 6;

    // 4 digit
    // nw => 2.5 up => 18 tp=>36

    printDoc.addPageMode(
      StarXpandPageMode()
        ..style(bold: false, magnification: StarXpandStyleMagnification(1, 1))
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
        ..actionPrintText("LINE1")
        ..style(horizontalPositionTo: 18, verticalPositionTo: tableHeaderY)
        ..actionPrintText("LINE2")
        ..style(
          horizontalPositionTo: 37,
          verticalPositionTo: tableHeaderY,
          bold: true,
        )
        ..actionPrintText("TOTAL PRICE")
        ..style(
          horizontalPositionTo: 2.5,
          verticalPositionTo: tableRowY,
          bold: false,
        )
        ..actionPrintText("99.99usd")
        ..style(
          horizontalPositionTo: 18,
          verticalPositionTo: tableRowY,
          bold: false,
        )
        ..actionPrintText("\$99.99")
        ..style(
          horizontalPositionTo: 40,
          verticalPositionTo: tableRowY + 1.5,
          bold: true,
          magnification: StarXpandStyleMagnification(1, 2),
        )
        ..actionPrintText("\$ 9.99")
        // ..actionPrintImage(halalLogo, 8, 10.5, 70)
        ..style(
          horizontalPositionTo: 33,
          verticalPositionTo: 12,
          bold: true,
          magnification: StarXpandStyleMagnification(1, 1),
        )
        ..actionPrintText("TICKET DATE")
        ..style(horizontalPositionTo: 33, verticalPositionTo: 16, bold: false)
        ..actionPrintText("11/11/2025"),
    );

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
    var displayDoc =
        StarXpandDocumentDisplay()
          ..actionClearAll()
          ..actionClearLine()
          ..actionShowText("StarXpand\n")
          ..actionClearLine()
          ..actionShowText("Updated ${++displayCounterText} times");

    StarXpand.updateDisplay(printer, displayDoc);
  }

  void _getStatus(StarXpandPrinter printer) async {
    // TODO: Implemented for android only
    try {
      var status = await StarXpand.getStatus(printer);
      print("Got status ${status.toString()}");
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: SafeArea(
        top: true,
        bottom: true,
        child: CupertinoPageScaffold(
          // appBar: AppBar(title: const Text('TEST APP')),
          navigationBar: const CupertinoNavigationBar(
            middle: Text('STARMICRONICS TEST'),
            enableBackgroundFilterBlur: true,
          ),
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              CupertinoButton.filled(
                child: Text('Search for devices'),
                onPressed: () => findPrinters(),
              ),
              if (printers != null)
                for (var p in printers!)
                  CupertinoListTile(
                    title: Text(
                      "${p.model.label} / ${p.model.name} / ${p.interface.name}",
                    ),
                    subtitle: Text(p.identifier),
                    additionalInfo: Row(
                      spacing: 4,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                          onPressed: () => handlePrint1(p),
                          child: const Text("P1"),
                        ),

                        CupertinoButton(
                          onPressed: () => handlePrintGraphic(p),
                          child: const Text("P2"),
                        ),

                        //     CupertinoButton(
                        //       onPressed: () => _openDrawer(p),
                        //       child: const Text("Open drawer"),
                        //     ),

                        //     // OutlinedButton(
                        //     //     onPressed: () => _updateDisplayText(p),
                        //     //     child: Text("Update display")),
                        //     CupertinoButton(
                        //       onPressed: () => _getStatus(p), // TODO: Android only
                        //       child: const Text("Get Status"),
                        // ),
                      ],
                    ),
                  ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [const Text("LOG:"), Text(log)],
                  ),
                ),
              ),
            ],
          ).paddingOnly(
            top: CupertinoNavigationBar().preferredSize.height + 8,
            left: 8,
            right: 8,
            bottom: 8,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
