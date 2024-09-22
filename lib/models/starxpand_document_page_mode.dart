import 'package:starxpand/models/starxpand_document.dart';

class StarXpandDocumentPageMode extends StarXpandDocumentContent {
  final List<Map> _actions = [];

  @override
  String get type => 'page_mode';

  List<Map> getActions() {
    return _actions;
  }

  @override
  Map getData() {
    return {"actions": _actions};
  }
}

extension MapTrim on Map {
  trim() {
    removeWhere((key, value) => value == null);
  }
}
