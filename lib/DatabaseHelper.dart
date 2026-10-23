
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  static final Databasehelper _instance = Databasehelper._internal();
  static Database? _database;

  factory Databasehelper() {
    return _instance;
  }

  Databasehelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, 'if.db'),
      version: 2,

      // Activa las claves foráneas.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla Estudante.
    await db.execute('''
      CREATE TABLE estudante(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        matricula TEXT
      )
    ''');

    await _criarOutrasTabelas(db);
  }

  Future<void> _criarOutrasTabelas(Database db) async {
    // Tabla Disciplina.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS disciplina(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        profesor TEXT
      )
    ''');

    // Tabla Cursando: relación N:N.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cursando(
        id_estudante INTEGER NOT NULL,
        id_disciplina INTEGER NOT NULL,

        PRIMARY KEY(id_estudante, id_disciplina),

        FOREIGN KEY(id_estudante)
          REFERENCES estudante(id)
          ON DELETE CASCADE,

        FOREIGN KEY(id_disciplina)
          REFERENCES disciplina(id)
          ON DELETE CASCADE
      )
    ''');
  }

  
  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _criarOutrasTabelas(db);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
