
import 'package:flutter/material.dart';
import 'package:crudbs/disciplina.dart';
import 'package:crudbs/disciplina_dao.dart';

class DisciplinaPage extends StatefulWidget {
  const DisciplinaPage({super.key});

  @override
  State<DisciplinaPage> createState() => _DisciplinaPageState();
}

class _DisciplinaPageState extends State<DisciplinaPage> {
  final _dao = DisciplinaDao();

  final _nome = TextEditingController();
  final _profesor = TextEditingController();

  List<Disciplina> _lista = [];
  Disciplina? _atual;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // Buscar disciplinas en la base de datos.
  Future<void> _carregar() async {
    final dados = await _dao.listarDisciplinas();

    if (!mounted) return;
    setState(() {
      _lista = dados;
    });
  }

  // Insertar o actualizar disciplina.
  Future<void> _salvar() async {
    if (_nome.text.trim().isEmpty ||
        _profesor.text.trim().isEmpty) {
      return;
    }

    final disciplina = Disciplina(
      id: _atual?.id,
      nome: _nome.text.trim(),
      profesor: _profesor.text.trim(),
    );

    if (_atual == null) {
      await _dao.incluirDisciplina(disciplina);
    } else {
      await _dao.editarDisciplina(disciplina);
    }

    if (!mounted) return;

    _nome.clear();
    _profesor.clear();
    setState(() => _atual = null);

    await _carregar();
  }

  // Eliminar disciplina.
  Future<void> _apagar(int id) async {
    await _dao.deleteDisciplina(id);
    await _carregar();
  }

  @override
  void dispose() {
    _nome.dispose();
    _profesor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUD Disciplina"),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _nome,
              decoration: const InputDecoration(
                labelText: "Nome da disciplina",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _profesor,
              decoration: const InputDecoration(
                labelText: "Professor",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _salvar,
            child: Text(
              _atual == null ? "Salvar" : "Atualizar",
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _lista.length,
              itemBuilder: (context, index) {
                final d = _lista[index];

                return ListTile(
                  title: Text(d.nome),
                  subtitle: Text(d.profesor),

                  // Seleccionar para editar.
                  onTap: () {
                    setState(() {
                      _atual = d;
                      _nome.text = d.nome;
                      _profesor.text = d.profesor;
                    });
                  },

                  // Eliminar.
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _apagar(d.id!),
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
