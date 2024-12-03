// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stikev/database/tables/table_profile.dart';
import 'package:stikev/database/tables/table_route.dart';

class DBInitializer {
  static String get dbName => dotenv.env['DB']!;

  static Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, dbName);

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Crear tablas aquí
        await TableProfile.createTable(db);
        await TableRoute.createTable(db);
      },
      onOpen: (db) async {
        // Verificar y agregar columnas faltantes cada vez que la base de datos se abre
        await TableProfile.verifyAndAddMissingColumns(db);
        await TableRoute.verifyAndAddMissingColumns(db);
      },
    );
  }
}
