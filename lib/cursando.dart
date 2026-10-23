
class Cursando {
  int idEstudante;
  int idDisciplina;

  Cursando({
    required this.idEstudante,
    required this.idDisciplina,
  });

  // Convierte el objeto en un mapa.
  Map<String, dynamic> toMap() {
    return {
      "id_estudante": idEstudante,
      "id_disciplina": idDisciplina,
    };
  }

  // Convierte un mapa en un objeto.
  factory Cursando.fromMap(Map<String, dynamic> map) {
    return Cursando(
      idEstudante: map['id_estudante'],
      idDisciplina: map['id_disciplina'],
    );
  }
}
