import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './api.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'dart:typed_data';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

const String DB_SRC = "https://raw.githubusercontent.com/arma7x/opendosm-parquet-to-sqlite/master/pricecatcher.zip";

class Api extends BaseApi {

  @override
  Future<CommonDatabase> GetDatabase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int latestContentLength = 0;
    try {
      if (await Permission.storage.request().isDenied) {
        await Permission.storage.request();
      }
      final responseHeader = await http.head(Uri.parse(DB_SRC));
      if (responseHeader.statusCode == 200) {
        latestContentLength = int.parse(responseHeader.headers["content-length"]!);
      } else {
        latestContentLength = -1;
      }

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      File dbFile = File(path.join(documentsDirectory.path, "pricecatcher.db"));

      if (dbFile.existsSync() == false && latestContentLength == -1) {
        throw('Error HEAD: ${DB_SRC}');
      }

      int currentContentLength = prefs.getInt('contentLength') ?? 0;

      Uint8List zipUint8List = Uint8List(0);
      if (dbFile.existsSync() == false || (latestContentLength != -1 && latestContentLength != currentContentLength)) {
        final response = await http.get(Uri.parse(DB_SRC));
        if (response.statusCode == 200) {
          await prefs.setInt('contentLength', int.parse(response.headers["content-length"]!));
          zipUint8List = response.bodyBytes as Uint8List;
        } else {
          throw('Error GET: ${DB_SRC}');
        }
      }

      final archive = ZipDecoder().decodeBytes(zipUint8List);
      for (final file in archive) {
        if (file.isFile) {
          if (dbFile.existsSync()) {
            dbFile.delete();
          }
          dbFile.writeAsBytesSync(file.content);
          break;
        }
      }
      final instance = await sqlite3.open(dbFile.path);
      return Future<CommonDatabase>.value(instance);
    } on Exception catch (e) {
      rethrow;
    }
  }
}
