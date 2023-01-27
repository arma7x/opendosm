import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as DOM;
import 'package:csv/csv.dart';
import '../ApiCommon.dart';

class Api with ApiHelper {

  static Future<List<Map<String, String>>> GetPriceCatcherList() async {
    try {
      final response = await http.get(Uri.parse("https://open.dosm.gov.my/data-catalogue"));
      if (response.statusCode == 200) {
        final DOM.Document document = parse(response.body);
        List<DOM.Element> sections = document.getElementsByTagName("section");
        List<DOM.Element> ul = [];
        for (var i = 0; i < sections.length; i++) {
          if (sections[i].children.length > 0 && sections[i].children[0].text.trim() == "Economy: PriceCatcher") {
            ul = [...sections[i].children[1].children];
            break;
          }
        }
        List<Map<String, String>> priceCatcher = [];
        ul = ul.reversed.toList();
        ul.forEach((li) {
          if (li.children[0].text.indexOf("PriceCatcher") > -1) {
            priceCatcher.add({ "name": li.children[0].text, "href": "https://open.dosm.gov.my${li.children[0].attributes['href']!}" });
          }
        });
        return Future<List<Map<String, String>>>.value(priceCatcher);
      } else {
        throw('Unknown error');
      }
    } on Exception catch (e) {
      rethrow;
    }
  }

}
