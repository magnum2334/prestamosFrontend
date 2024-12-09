import 'package:sqflite/sqflite.dart';

class TableRoute {
  static const String tableName = 'routes';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnCobradorId = 'cobradorId';
  static const String columnInteres = 'interes';
  static const String columnTMaximoPrestamo = 'tMaximoPrestamo';
  static const String columnInteresLibre = 'interesLibre';
  static const String columnCapitalId = 'capitalId';
  static const String columnFechaCreacion = 'fecha_creacion'; // Nueva columna

  // Crear la tabla inicial
  static Future<void> createTable(Database db) async {
    try {
      await db.execute(''' 
        CREATE TABLE IF NOT EXISTS $tableName (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnName TEXT NOT NULL,
          $columnDescription TEXT,
          $columnCobradorId INTEGER,
          $columnInteres INTEGER,
          $columnTMaximoPrestamo INTEGER,
          $columnInteresLibre INTEGER,
          $columnCapitalId INTEGER,
          $columnFechaCreacion TEXT NOT NULL
        )
      ''');
      print('Tabla $tableName creada correctamente');
    } catch (e) {
      print('Error al crear la tabla $tableName: $e');
    }
  }

  // Verificar y agregar columnas faltantes
  static Future<void> verifyAndAddMissingColumns(Database db) async {
    try {
      createTable(db);
      // Verificar las columnas existentes en la tabla
      final existingColumns = await _getExistingColumns(db);

      final Map<String, String> requiredColumns = {
        columnName: 'TEXT NOT NULL',
        columnDescription: 'TEXT',
        columnCobradorId: 'INTEGER',
        columnInteres: 'INTEGER',
        columnTMaximoPrestamo: 'INTEGER',
        columnInteresLibre: 'INTEGER',
        columnCapitalId: 'INTEGER',
        columnFechaCreacion: 'TEXT NOT NULL', // Nueva columna
      };

      // Agregar columnas faltantes
      for (var column in requiredColumns.entries) {
        if (!existingColumns.contains(column.key)) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN ${column.key} ${column.value}');
          print('Columna ${column.key} agregada a la tabla $tableName');
        }
      }
    } catch (e) {
      print('Error al verificar y agregar columnas faltantes: $e');
    }
  }

  // Obtener las columnas existentes en la tabla
  static Future<List<String>> _getExistingColumns(Database db) async {
    try {
      final result = await db.rawQuery('PRAGMA table_info($tableName)');
      return result.map((column) => column['name'] as String).toList();
    } catch (e) {
      print('Error al obtener columnas existentes: $e');
      return [];
    }
  }

  // Método para insertar o actualizar una ruta
  static Future<int> upsertRoute(
      Database db, Map<String, dynamic> routeData) async {
    await verifyAndAddMissingColumns(db);

    final existingRoute = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [routeData[columnId]],
    );

    if (existingRoute.isNotEmpty) {
      // Si existe, actualiza la ruta
      return await db.update(
        tableName,
        routeData,
        where: '$columnId = ?',
        whereArgs: [routeData[columnId]],
      );
    } else {
      // Si no existe, inserta un nuevo registro
      return await db.insert(tableName, routeData);
    }
  }

  // Método para obtener todas las rutas
  static Future<List<Map<String, dynamic>>> getRoutes(Database db) async {
    return await db.query(tableName);
  }
  // Método para eliminar todas las rutas
  static Future<int> deleteRoutes(Database db) async {
    // Eliminar todas las rutas de la tabla
    return await db.delete(tableName);
  }
}
