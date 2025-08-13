class ReglaIncumplida {
  final int idConsist;
  final String regla;
  final String descripcion; // Campo para la descripción
  final String idTren;
  final int idValidacion;
  final bool activo;

  ReglaIncumplida({
    required this.idConsist,
    required this.regla,
    required this.descripcion, // Asegúrate de que esté aquí
    required this.idTren,
    required this.idValidacion,
    required this.activo,
  });

  factory ReglaIncumplida.fromJson(Map<String, dynamic> json) {
    return ReglaIncumplida(
      idConsist: json['id_consist'] ?? 0,
      regla: json['regla'] ?? '',
      descripcion: json['descripcion'] ?? '',
      idTren: json['idTren'] ?? '',
      idValidacion: json['idValidacion'] ?? 0,
      activo: json['activo'] == 'T',
    );
  }
}
