class TrainData {
  final int id;
  final String autorizado;
  final String idTren;
  final String destino;
  final String fechaAutorizadoRechazado;
  final String llamadoPor;
  final String fechaEnvioLlamado;
  final String origen;
  final String fechaOfrecido;
  final String fechaValidado;
  final String llamado;
  final String ofrecido;
  final String ofrecidoPor;
  final String autorizadorPor;
  final String validado;
  final String ultimaEstacion;
  final String estacionActual;
  final String fechaLlamado;
  final int cargados;
  final int carros;
  final int vacios;
  final String validado_por;
  final String observaciones;
  final String observ_ofrecimiento;
  final String observ_autorizado;

  TrainData({
    required this.id,
    required this.autorizado,
    required this.idTren,
    required this.destino,
    required this.fechaAutorizadoRechazado,
    required this.llamadoPor,
    required this.fechaEnvioLlamado,
    required this.origen,
    required this.fechaOfrecido,
    required this.fechaValidado,
    required this.llamado,
    required this.ofrecido,
    required this.ofrecidoPor,
    required this.validado,
    required this.ultimaEstacion,
    required this.estacionActual,
    required this.fechaLlamado,
    required this.observaciones,
    required this.cargados,
    required this.carros,
    required this.vacios,
    required this.validado_por,
    required this.autorizadorPor,
    required this.observ_ofrecimiento,
    required this.observ_autorizado,
  });

  factory TrainData.fromJson(Map<String, dynamic> json) {
    var data = json['DataTren']['wrapper'];
    return TrainData(
      id: data['ID'] ?? 0,
      autorizado: data['autorizado'] ?? '',
      idTren: data['IdTren'] ?? '',
      destino: data['destino'] ?? '',
      fechaAutorizadoRechazado: data['fecha_autorizado'] ?? '',
      llamadoPor: data['llamado_por'] ?? '',
      fechaEnvioLlamado: data['fecha_autorizado'] ?? '',
      origen: data['origen'] ?? '',
      fechaOfrecido: data['fecha_ofrecido'] ?? '',
      fechaValidado: data['fecha_validado'] ?? '',
      llamado: data['llamado'] ?? '',
      ofrecido: data['ofrecido'] ?? '',
      ofrecidoPor: data['ofrecido_por'] ?? '',
      validado: data['validado'] ?? '',
      ultimaEstacion: data['ultima_estacion'] ?? '',
      estacionActual: data['estacion_actual'] ?? '',
      fechaLlamado: data['fecha_llamado'] ?? '',
      cargados: data['cargados'] ?? 0,
      carros: data['carros'] ?? 0,
      vacios: data['vacios'] ?? 0,
      validado_por: data['validado_por'] ?? 0,
      autorizadorPor: data['autorizado_por'] ?? '',
      observaciones: data['observaciones'] ?? '',
      observ_ofrecimiento: data['observ_ofrecimiento'] ?? '',    
      observ_autorizado: data['observ_autorizado']?? ''
    );
  }
}
