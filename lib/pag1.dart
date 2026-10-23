

import 'package:crudbs/estudante.dart';
import 'package:crudbs/estudante_dao.dart';
import 'package:crudbs/disciplina_page.dart';
import 'package:crudbs/cursando_page.dart';
import 'package:flutter/material.dart';

class pag1 extends StatefulWidget {
  const pag1({super.key});

  @override
  State<pag1> createState() => _pag1State();
}

class _pag1State extends State<pag1> {
  // Objeto para acceder a la base de datos.
  final _estudanteDAO = EstudanteDao();

  // Estudiante seleccionado para editar.
  Estudante? _estudanteAtual;

  // Controladores de los campos.
  final _controllerNome = TextEditingController();
  final _controllerMatricula = TextEditingController();

  // Lista de estudiantes.
  List<Estudante> _listaEstudantes = [];

  @override
  void initState() {
    super.initState();
    _loadEstudantes();
  }

  // READ: cargar estudiantes desde SQLite.
  Future<void> _loadEstudantes() async {
    List<Estudante> temp =
        await _estudanteDAO.listarEstudantes();

    if (!mounted) return;

    setState(() {
      _listaEstudantes = temp;
    });
  }

  // CREATE y UPDATE: guardar o editar estudiante.
  Future<void> _salvarOUEditar() async {
    // Comprobar que los campos no estén vacíos.
    if (_controllerNome.text.trim().isEmpty ||
        _controllerMatricula.text.trim().isEmpty) {
      return;
    }

    if (_estudanteAtual == null) {
      // Crear un estudiante nuevo.
      await _estudanteDAO.incluirEstudante(
        Estudante(
          nome: _controllerNome.text,
          matricula: _controllerMatricula.text,
        ),
      );
    } else {
      // Actualizar estudiante existente.
      _estudanteAtual!.nome = _controllerNome.text;
      _estudanteAtual!.matricula =
          _controllerMatricula.text;

      await _estudanteDAO.editarEstudante(
        _estudanteAtual!,
      );
    }

    if (!mounted) return;

    // Limpiar campos.
    _controllerNome.clear();
    _controllerMatricula.clear();

    setState(() {
      _estudanteAtual = null;
    });

    // Actualizar la lista.
    await _loadEstudantes();
  }

  // DELETE: eliminar estudiante.
  Future<void> _apagarEstudante(int id) async {
    await _estudanteDAO.deleteEstudante(id);
    await _loadEstudantes();
  }

  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerMatricula.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUD Estudante"),
        backgroundColor: Colors.cyan,

        // Botones para las otras pantallas.
        actions: [
          // Pantalla Disciplina.
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: "Disciplinas",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const DisciplinaPage(),
                ),
              );
            },
          ),

          // Pantalla Cursando.
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: "Cursando",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CursandoPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Campo para el nombre.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controllerNome,
              decoration: const InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),

          // Campo para la matrícula.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controllerMatricula,
              decoration: const InputDecoration(
                labelText: "Matricula",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),

          // Botón Guardar / Actualizar.
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () {
                _salvarOUEditar();
              },
              child: Text(
                _estudanteAtual == null
                    ? "Salvar"
                    : "Atualizar",
              ),
            ),
          ),

          // Lista de estudiantes registrados.
          Expanded(
            child: ListView.builder(
              itemCount: _listaEstudantes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // Nombre del estudiante.
                  title: Text(
                    _listaEstudantes[index].nome,
                  ),

                  // Matrícula del estudiante.
                  subtitle: Text(
                    _listaEstudantes[index].matricula,
                  ),

                  // Botón eliminar.
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _apagarEstudante(
                        _listaEstudantes[index].id!,
                      );
                    },
                  ),

                  // Seleccionar estudiante para editar.
                  onTap: () {
                    setState(() {
                      _estudanteAtual =
                          _listaEstudantes[index];

                      _controllerNome.text =
                          _estudanteAtual!.nome;

                      _controllerMatricula.text =
                          _estudanteAtual!.matricula;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
