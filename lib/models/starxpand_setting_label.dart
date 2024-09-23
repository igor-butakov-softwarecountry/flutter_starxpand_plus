import 'package:starxpand/models/starxpand_document.dart';
import 'package:starxpand/starxpand.dart';

class StarXpandDocumentSettingLabel extends StarXpandDocumentContent {
  final List<Map> _actions = [];

  StarXpandDocumentSettingLabel();

  setEnable(bool enable) {
    _actions.add({'action': 'setEnable', 'enable': enable});
  }

  @override
  String get type => 'settingLabel';

  @override
  Map getData() {
    return {"actions": _actions};
  }
}
