import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as DOM;

class Api {

  static Future<Map<String, dynamic>> GetData() async {
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
        Map<String, String> itemLookup = {};
        Map<String, String> premiseLookup = {};
        List<Map<String, String>> priceCatcher = [];
        ul = ul.reversed.toList();
        ul.forEach((li) {
          if (li.children[0].text.indexOf("PriceCatcher") > -1) {
            priceCatcher.add({ "name": li.children[0].text, "href": "https://open.dosm.gov.my${li.children[0].attributes['href']!}" });
          } else if (li.children[0].text.indexOf("Item Lookup") > -1) {
            itemLookup = { "name": li.children[0].text, "href": "https://open.dosm.gov.my${li.children[0].attributes['href']!}" };
          } else if (li.children[0].text.indexOf("Premise Lookup") > -1) {
            premiseLookup = { "name": li.children[0].text, "href": "https://open.dosm.gov.my${li.children[0].attributes['href']!}" };
          }
        });
        return Future<Map<String, dynamic>>.value({ "priceCatcher": priceCatcher, "itemLookup": itemLookup, "premiseLookup": premiseLookup });
      } else {
        throw('Unknown error');
      }
    } on Exception catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> ExtractData(String href) async {
    try {
      final response = await http.get(Uri.parse(href));
      if (response.statusCode == 200) {
        Map<String, dynamic> result = {};
        final DOM.Document document = parse(response.body);
        List<DOM.Element> scripts = document.getElementsByTagName("script");
        for (var i = 0; i < scripts.length; i++) {
          if (scripts[i].attributes["id"] != null && scripts[i].attributes["id"] == "__NEXT_DATA__") {
            final __NEXT_DATA__ = json.decode(scripts[i].text);
            result = __NEXT_DATA__["props"]!["pageProps"]!["dataset"]!;
            break;
          }
        }
        return Future<Map<String, dynamic>>.value(result);
      } else {
        throw('Unknown error');
      }
    } on Exception catch (e) {
      rethrow;
    }
  }

}
