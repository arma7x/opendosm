import 'package:sqlite3/common.dart';

abstract class BaseApi {
  Future<CommonDatabase> GetDatabase();
}
