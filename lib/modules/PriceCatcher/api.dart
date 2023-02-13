import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as DOM;
import 'package:csv/csv.dart';
import '../ApiCommon.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'dart:typed_data';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/wasm.dart';

class Api with ApiHelper {

  static GetDatabaseWeb() async {
    try {
      IdbFactory idbFactory = getIdbFactory()!;
      final storeName = 'opendosm';
      final db = await idbFactory.open('price_catcher', version: 1,
          onUpgradeNeeded: (VersionChangeEvent event) {
          final db = event.database;
          db.createObjectStore(storeName, autoIncrement: true);
      });

      var txn = db.transaction(storeName, "readonly");
      var store = txn.objectStore(storeName);
      var byteArray = await store.getObject("zip");
      await txn.completed;

      if (byteArray == null) {
        final response = await http.get(Uri.parse("https://raw.githubusercontent.com/arma7x/opendosm-parquet-to-sqlite/master/pricecatcher.zip"));
        if (response.statusCode == 200) {
          // String dir = (await getTemporaryDirectory()).path;
          txn = db.transaction(storeName, "readwrite");
          store = txn.objectStore(storeName);
          await store.put(response.bodyBytes, "zip");
          await store.put(response.contentLength!, "contentLength");
          await txn.completed;
          byteArray = response.bodyBytes;
        } else {
          throw('Unknown error');
        }
      }
      Uint8List dbUint8List = Uint8List(0);
      final archive = ZipDecoder().decodeBytes(byteArray as Uint8List);
      for (final file in archive) {
        if (file.isFile) {
          dbUint8List = file.content as Uint8List;
          break;
        }
      }
      final response = await http.get(Uri.parse('sqlite3.wasm'));
      final fs = await IndexedDbFileSystem.open(dbName: 'opendosm_pricecatcher_database');
      if (!fs.exists("/pricecatcher.db")) {
        fs..createFile("/pricecatcher.db")..write("/pricecatcher.db", dbUint8List as Uint8List, 0);
      }
      final sqlite = await WasmSqlite3.load(response.bodyBytes, SqliteEnvironment(fileSystem: fs));
      final dbSQL = await sqlite.open('/pricecatcher.db');
      print(dbSQL.select('''
        SELECT *
        FROM items
        LIMIT 2
        '''
      ));
    } on Exception catch (e) {
      throw(e);
      // rethrow;
    }
  }

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
