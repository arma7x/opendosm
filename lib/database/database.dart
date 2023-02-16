import 'package:sqlite3/common.dart';

abstract class BaseDatabase {
  Future<CommonDatabase> GetDatabase();
}
