
import 'package:crudbs/DatabaseHelper.dart';
import 'package:crudbs/cursando.dart';

class CursandoDao {
  final Databasehelper _dbHelper = Databasehelper();

  // CREATE: registrar una relación.
  Future<void> incluirCursando(Cursando c) async {
    final db = await _dbHelper.database;

    await db.insert(
      "cursando",
      c.toMap(),
    );
  }

  // UPDATE: cambiar la relación.
  Future<void> editarCursando(
    Cursando anterior,
    Cursando nuevo,
  ) async {
    final db = await _dbHelper.database;

    await db.update(
      "cursando",
      nuevo.toMap(),
      where: "id_estudante = ? AND id_disciplina = ?",
      whereArgs: [
        anterior.idEstudante,
        anterior.idDisciplina,
      ],
    );
  }

  // DELETE: eliminar una relación.
  Future<void> deleteCursando(Cursando c) async {
    final db = await _dbHelper.database;

    await db.delete(
      "cursando",
      where: "id_estudante = ? AND id_disciplina = ?",
      whereArgs: [
        c.idEstudante,
        c.idDisciplina,
      ],
    );
  }

  // READ: listar las relaciones utilizando JOIN.
  Future<List<Map<String, Object?>>> listarCursando() async {
    final db = await _dbHelper.database;

    return await db.rawQuery('''
      SELECT
        c.id_estudante,
        c.id_disciplina,
        e.nome AS estudante_nome,
        d.nome AS disciplina_nome
      FROM cursando c
      INNER JOIN estudante e
        ON c.id_estudante = e.id
      INNER JOIN disciplina d
        ON c.id_disciplina = d.id
      ORDER BY e.nome, d.nome
    ''');
  }
}
