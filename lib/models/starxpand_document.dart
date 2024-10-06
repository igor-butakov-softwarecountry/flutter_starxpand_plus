import 'package:starxpand/models/starxpand_document_buzzer.dart';
import 'package:starxpand/models/starxpand_document_display.dart';
import 'package:starxpand/starxpand.dart';

class StarXpandDocument {
  final List<StarXpandDocumentContent> _contents = [];

  addPrint(StarXpandDocumentPrint print) => _contents.add(print);
  addBuzzer(StarXpandDocumentBuzzer buzzer) => _contents.add(buzzer);
  addDrawer(StarXpandDocumentDrawer drawer) => _contents.add(drawer);
  addDisplay(StarXpandDocumentDisplay display) => _contents.add(display);

  Map toMap() {
    return {"contents": _contents.map((e) => e.toMap()).toList()};
  }
}

abstract class StarXpandDocumentContent {
  String get type;

  Map? getData();

  Map toMap() {
    return {"type": type, "data": getData()};
  }
}
