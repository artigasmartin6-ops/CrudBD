
class Disciplina {
  int? id;
  String nome;
  String profesor;

  Disciplina({
    this.id,
    required this.nome,
    required this.profesor,
  });

  
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "profesor": profesor,
    };
  }

  
  factory Disciplina.fromMap(Map<String, dynamic> map) {
    return Disciplina(
      id: map['id'],
      nome: map['nome'],
      profesor: map['profesor'],
    );
  }
}
