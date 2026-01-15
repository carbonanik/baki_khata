import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class DatabaseService {
  static final DatabaseService _singleton = DatabaseService._();
  static DatabaseService get instance => _singleton;
  DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, 'baki_khata.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }
}
