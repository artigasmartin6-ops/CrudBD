
import 'package:crudbs/DatabaseHelper.dart';
import 'package:crudbs/disciplina.dart';
import 'package:sqflite/sqflite.dart';

class DisciplinaDao {
  final Databasehelper _dbHelper = Databasehelper();

  // Incluir disciplina.
  Future<void> incluirDisciplina(Disciplina e) async {
    final db = await _dbHelper.database;

    await db.insert(
      "disciplina",
      e.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Editar disciplina.
  Future<void> editarDisciplina(Disciplina e) async {
    final db = await _dbHelper.database;

    await db.update(
      "disciplina",
      e.toMap(),
      where: "id = ?",
      whereArgs: [e.id],
    );
  }

  // Eliminar disciplina.
  Future<void> deleteDisciplina(int index) async {
    final db = await _dbHelper.database;

    await db.delete(
      "disciplina",
      where: "id = ?",
      whereArgs: [index],
    );
  }

  // Listar disciplinas.
  Future<List<Disciplina>> listarDisciplinas() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps =
        await db.query("disciplina");

    return List.generate(maps.length, (index) {
      return Disciplina.fromMap(maps[index]);
    });
  }
}
