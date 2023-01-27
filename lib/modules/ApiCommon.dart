import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as DOM;
import 'package:csv/csv.dart';

mixin ApiHelper {

  Future<List<Map<String, dynamic>>> LookupCSV(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];
        final lines = const CsvToListConverter().convert(response.body.toString());
        for (var i=1;i<lines.length;i++) {
          Map<String, dynamic> temp = {};
          if (int.parse(lines[i][0].toString()) > -1) {
            lines[0].asMap().forEach((index, h) {
              temp[h] = lines[i][index];
            });
            result.add(temp);
          }
        }
        return Future<List<Map<String, dynamic>>>.value(result);
      } else {
        throw('Unknown error');
      }
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> ScrapDataset(String href) async {
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
