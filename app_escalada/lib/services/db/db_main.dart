import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBMain {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'database.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE perfiles(
            id_perfil TEXT PRIMARY KEY,
            nombre_perfil TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE entrenamientos(
            id_entrenamiento INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre_entrenamiento TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE entrenamiento_detalles(
            id_entrenamiento_detalles INTEGER PRIMARY KEY AUTOINCREMENT,
            id_perfil TEXT NOT NULL,
            id_entrenamiento INTEGER NOT NULL,
            peso_objetivo REAL,
            repeticiones INTEGER,
            series INTEGER,
            descanso_repeticion REAL,
            descanso_serie REAL,
            duracion_repeticion REAL,
            duracion_total REAL,
            fecha TEXT NOT NULL,
            FOREIGN KEY (id_perfil) REFERENCES perfiles(id_perfil) ON DELETE CASCADE,
            FOREIGN KEY (id_entrenamiento) REFERENCES entrenamientos(id_entrenamiento) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE datos(
            id_entrenamiento_detalles INTEGER NOT NULL,
            num_repeticion INTEGER NOT NULL,
            num_serie INTEGER NOT NULL,
            tiempo REAL NOT NULL,
            peso REAL,
            PRIMARY KEY (id_entrenamiento_detalles, num_repeticion, num_serie, tiempo),
            FOREIGN KEY (id_entrenamiento_detalles) REFERENCES entrenamiento_detalles(id_entrenamiento_detalles) ON DELETE CASCADE
          )
        ''');

        // ENTRENAMIENTOS POR DEFECTO
        await db.insert('entrenamientos', {
          'nombre_entrenamiento': 'Isometrico',
        });
        await db.insert('entrenamientos', {
          'nombre_entrenamiento': 'Repeticiones',
        });
      },
    );

    return _db!;
  }
}
