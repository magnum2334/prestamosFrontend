import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:stikev/getX/LoginController.dart';

class TableProfile {
  static const String tableName = 'profile';
  static const String columnId = 'id';
  static const String columnUserId = 'userId';
  static const String columnName = 'name';
  static const String columnEmail = 'email';
  static const String columnPhone = 'phone';
  static const String columnStatus = 'status';
  static const String columnToken = 'token';
  static const String columnRoleId = 'roleId';
  static const String columnTokenUpdateDate = 'tokenUpdateDate';

  // Crear la tabla inicial
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUserId TEXT NOT NULL UNIQUE,
        $columnName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnPhone TEXT,
        $columnStatus TEXT,
        $columnToken TEXT,
        $columnRoleId INTEGER,
        $columnTokenUpdateDate TEXT
      )
    ''');
  }

  // Verificar y agregar columnas faltantes
  static Future<void> verifyAndAddMissingColumns(Database db) async {
    final existingColumns = await _getExistingColumns(db);
    final Map<String, String> requiredColumns = {
      columnUserId: 'TEXT NOT NULL UNIQUE',
      columnName: 'TEXT NOT NULL',
      columnEmail: 'TEXT NOT NULL',
      columnPhone: 'TEXT',
      columnStatus: 'TEXT',
      columnToken: 'TEXT',
      columnRoleId: 'INTEGER',
      columnTokenUpdateDate: 'TEXT',
    };

    for (var column in requiredColumns.entries) {
      if (!existingColumns.contains(column.key)) {
        await db.execute(
            'ALTER TABLE $tableName ADD COLUMN ${column.key} ${column.value}');
      }
    }
  }

  // Obtener las columnas existentes en la tabla
  static Future<List<String>> _getExistingColumns(Database db) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.map((column) => column['name'] as String).toList();
  }

  static Future<bool> isTokenRegisteredToday(Database db) async {
    final LoginController loginController = Get.put(LoginController());
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await db.query(
      tableName,
      where: '$columnTokenUpdateDate = ?',
      whereArgs: [today],
      limit: 1,
    );
    if(result.isNotEmpty){
      loginController.setToken(result.first['token'].toString());
    }
    return result.isNotEmpty ? true : false;
  }

  // Método para insertar o actualizar un perfil
  static Future<int> upsertProfile(
      Database db, Map<String, dynamic> profileData) async {
    await verifyAndAddMissingColumns(db);

    final existingProfile = await db.query(
      tableName,
      where: '$columnUserId = ?',
      whereArgs: [profileData[columnUserId]],
    );

    if (existingProfile.isNotEmpty) {
      // Si existe, actualiza el perfil
      return await db.update(
        tableName,
        profileData,
        where: '$columnUserId = ?',
        whereArgs: [profileData[columnUserId]],
      );
    } else {
      // Si no existe, inserta un nuevo registro
      return await db.insert(tableName, profileData);
    }
  }
}
