import 'package:starxpand/models/starxpand_document.dart';
import 'package:starxpand/starxpand.dart';

enum StarXpandDocumentBuzzerChannel { no1, no2 }

class StarXpandDocumentBuzzer extends StarXpandDocumentContent {
  final StarXpandDocumentBuzzerChannel channel;

  StarXpandDocumentBuzzer({this.channel = StarXpandDocumentBuzzerChannel.no1});

  @override
  String get type => 'buzzer';

  @override
  Map getData() {
    return {"channel": channel.name};
  }
}
