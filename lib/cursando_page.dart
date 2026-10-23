
import 'package:flutter/material.dart';
import 'package:crudbs/estudante.dart';
import 'package:crudbs/estudante_dao.dart';
import 'package:crudbs/disciplina.dart';
import 'package:crudbs/disciplina_dao.dart';
import 'package:crudbs/cursando.dart';
import 'package:crudbs/cursando_dao.dart';

class CursandoPage extends StatefulWidget {
  const CursandoPage({super.key});

  @override
  State<CursandoPage> createState() => _CursandoPageState();
}

class _CursandoPageState extends State<CursandoPage> {
  final _dao = CursandoDao();

  List<Estudante> _estudantes = [];
  List<Disciplina> _disciplinas = [];
  List<Map<String, Object?>> _lista = [];

  int? _idEstudante;
  int? _idDisciplina;
  Cursando? _atual;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // Obtener estudiantes, disciplinas y relaciones.
  Future<void> _carregar() async {
    final estudantes =
        await EstudanteDao().listarEstudantes();

    final disciplinas =
        await DisciplinaDao().listarDisciplinas();

    final cursando = await _dao.listarCursando();

    if (!mounted) return;

    setState(() {
      _estudantes = estudantes;
      _disciplinas = disciplinas;
      _lista = cursando;
    });
  }

  // Guardar o editar una relación.
  Future<void> _salvar() async {
    if (_idEstudante == null || _idDisciplina == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione estudante e disciplina"),
        ),
      );
      return;
    }

    final novo = Cursando(
      idEstudante: _idEstudante!,
      idDisciplina: _idDisciplina!,
    );

    try {
      if (_atual == null) {
        await _dao.incluirCursando(novo);
      } else {
        await _dao.editarCursando(_atual!, novo);
      }
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Não foi possível salvar. Verifique se a relação já existe.",
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _atual = null;
      _idEstudante = null;
      _idDisciplina = null;
    });

    await _carregar();
  }

  Future<void> _apagar(Cursando c) async {
    await _dao.deleteCursando(c);
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUD Cursando"),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          // Seleccionar estudiante.
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<int>(
              isExpanded: true,
              hint: const Text("Selecione um estudante"),
              value: _idEstudante,
              items: _estudantes.map((e) {
                return DropdownMenuItem<int>(
                  value: e.id,
                  child: Text(e.nome),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() => _idEstudante = valor);
              },
            ),
          ),

          // Seleccionar disciplina.
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<int>(
              isExpanded: true,
              hint: const Text("Selecione uma disciplina"),
              value: _idDisciplina,
              items: _disciplinas.map((d) {
                return DropdownMenuItem<int>(
                  value: d.id,
                  child: Text(d.nome),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() => _idDisciplina = valor);
              },
            ),
          ),

          ElevatedButton(
            onPressed: _salvar,
            child: Text(
              _atual == null ? "Salvar" : "Atualizar",
            ),
          ),

          // Lista con resultado del JOIN.
          Expanded(
            child: ListView.builder(
              itemCount: _lista.length,
              itemBuilder: (context, index) {
                final registro = _lista[index];

                final c = Cursando(
                  idEstudante: registro['id_estudante'] as int,
                  idDisciplina: registro['id_disciplina'] as int,
                );

                return ListTile(
                  title: Text(
                    "${registro['estudante_nome']} - "
                    "${registro['disciplina_nome']}",
                  ),

                  // Seleccionar para actualizar.
                  onTap: () {
                    setState(() {
                      _atual = c;
                      _idEstudante = c.idEstudante;
                      _idDisciplina = c.idDisciplina;
                    });
                  },

                  // Eliminar.
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _apagar(c),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
