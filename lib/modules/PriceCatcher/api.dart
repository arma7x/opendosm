import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'dart:typed_data';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/wasm.dart';

const String SOURCE = "https://raw.githubusercontent.com/arma7x/opendosm-parquet-to-sqlite/master/pricecatcher.zip";

class Api {

  static Future<CommonDatabase> GetDatabaseWeb() async {
    int latestContentLength = 0;
    try {
      final responseHeader = await http.head(Uri.parse(SOURCE));
      if (responseHeader.statusCode == 200) {
        latestContentLength = int.parse(responseHeader.headers["content-length"]!);
      } else {
        latestContentLength = -1;
      }
      IdbFactory idbFactory = getIdbFactory()!;
      final storeName = 'price_catcher';
      final db = await idbFactory.open('opendosm', version: 1,
          onUpgradeNeeded: (VersionChangeEvent event) {
          final db = event.database;
          db.createObjectStore(storeName, autoIncrement: true);
      });

      var txn = db.transaction(storeName, "readonly");
      var store = txn.objectStore(storeName);
      var zipUint8Array = await store.getObject("zip");
      int currentContentLength = await store.getObject("contentLength") as int ?? 0;
      await txn.completed;

      if (zipUint8Array == null && latestContentLength == -1) {
        throw('Error HEAD: ${SOURCE}');
      }

      if (zipUint8Array == null || (latestContentLength != -1 && latestContentLength != currentContentLength)) {
        final response = await http.get(Uri.parse(SOURCE));
        if (response.statusCode == 200) {
          // String dir = (await getTemporaryDirectory()).path;
          txn = db.transaction(storeName, "readwrite");
          store = txn.objectStore(storeName);
          await store.put(response.bodyBytes, "zip");
          await store.put(int.parse(response.headers["content-length"]!), "contentLength");
          await txn.completed;
          zipUint8Array = response.bodyBytes;
        } else {
          throw('Error GET: ${SOURCE}');
        }
      }
      Uint8List dbUint8List = Uint8List(0);
      final archive = ZipDecoder().decodeBytes(zipUint8Array as Uint8List);
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
      final instance = await sqlite.open('/pricecatcher.db');
      return Future<CommonDatabase>.value(instance);
    } on Exception catch (e) {
      rethrow;
    }
  }

  //static Future<CommonDatabase> GetDatabaseAndroid() async {

  //}
}
