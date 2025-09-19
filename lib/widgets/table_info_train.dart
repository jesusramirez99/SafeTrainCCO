import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:safe_train_cco/modelos/regla_incumplida_model.dart';
import 'package:safe_train_cco/modelos/regla_incumplida_provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class InfoTrainTable extends StatefulWidget {
  final String trainInfo;
  final String estacion;
  final VoidCallback toggleTableInfo;


  const InfoTrainTable({
    super.key,
    required this.trainInfo,
    required this.estacion,
    required this.toggleTableInfo,
  });

  @override
  State<InfoTrainTable> createState() => _InfoTrainTableState();
}

class _InfoTrainTableState extends State<InfoTrainTable> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<TablesTrainsProvider>(context, listen: false);
      provider.consistTren(context, widget.trainInfo, widget.estacion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TablesTrainsProvider>(context);
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return provider.infoTrain.isNotEmpty
        ? SizedBox(
            width: isLaptop? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.8,
            height: isLaptop? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.8,
            child: _buildStickyTable(provider.infoTrain),
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildStickyTable(List<Map<String, dynamic>> infoTrain) {
    final trenProvider = Provider.of<TrenYFechaModel>(context, listen: false);
    final tren = trenProvider.trenYFecha;
    List<String> headers = [
      'Secuencia',
      'Unidad',
      'Estatus',
      'Tipo de Equipo',
      'Peso\nBruto',
      'Articulados',
      'Peso\nArticulado',
      'Longitud',
      'Tipo\nLocomotora',
      'Lotear A',
      'Producto',
      'HG',
    ];

    List<List<String>> data = infoTrain.map((item) {
      return [
        item['posicion'].toString(),
        item['unidad'].toString(),
        item['estatus'].toString(),
        item['tipo_equipo'].toString(),
        item['peso'].toString(),
        item['articulados'] == 0 ? '' : item['articulados'].toString(),
        item['pesoArt'] == 0 ? '' : item['pesoArt'].toString(),
        item['longitud'].toString(),
        item['tipo_locomotora']?.toString() ?? '',
        item['lotearA'].toString(),
        item['producto'].toString(),
        item['hg'] == 0 ? '' : item['hg'].toString(),
      ];
    }).toList();

    List<String> reglas =
        infoTrain.map((item) => item['regla'].toString()).toList();

    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');

    return isLaptop?


    Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              Text(
              'Información del Tren: $tren',
                style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            /*Expanded(
                  child: SizedBox(
                    width: 1500, // 👈 ajusta el ancho total según tus columnas
                    child: StickyHeadersTable(
                      columnsLength: headers.length,
                      rowsLength: data.length,
                      columnsTitleBuilder: (i) => _buildHeaderCell(headers[i]),
                      rowsTitleBuilder: (i) => _buildRowHeaderCell(
                        '${i + 1}',
                        mostrarIcono: reglas[i].toString().trim() == 'F',
                        item: infoTrain[i],
                      ),
                      contentCellBuilder: (i, j) =>
                          _buildDataCell(data[j], i, reglas[j], infoTrain[j]),
                      legendCell: Container(),
                      cellDimensions: CellDimensions.variableColumnWidth(
                        columnWidths: List.generate(headers.length, (index) {
                          switch (headers[index]) {
                            case 'Secuencia': return 80;
                            case 'Unidad': return 90;
                            case 'Estatus': return 70;
                            case 'Tipo de Equipo': return 110;
                            case 'Articulados': return 105;
                            case 'Peso\nArticulado': return 120;
                            case 'Peso\nBruto': return 70;
                            case 'Longitud': return 80;
                            default: return 95;
                          }
                        }),
                        contentCellHeight: 60,
                        stickyLegendWidth: 0,
                        stickyLegendHeight: 60,
                      ),
                    ),
                  ),
                
                
            ),*/
            Expanded(
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1500, // 👈 ancho total de la tabla
                headingRowHeight: 60,
                dataRowHeight: 60,
                decoration: _cabeceraTabla(),
                // columnas
                border: const TableBorder(
                  horizontalInside: BorderSide(color: Colors.black, width: 1),
                ),
                columns: headers.map((header) {
                  return DataColumn2(
                    label: Center(
                      child: Text(
                        header,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    size: ColumnSize.M, // 👈 puedes jugar con S, M, L
                  );
                }).toList(),

                // filas
                rows: List.generate(data.length, (rowIndex) {
                  return DataRow(
                    color: MaterialStateProperty.all(const Color.fromARGB(255, 255, 252, 252)),
                    cells: List.generate(headers.length, (colIndex) {
                      return DataCell(
                        _buildDataCell(
                          data[rowIndex],
                          colIndex,
                          reglas[rowIndex],
                          infoTrain[rowIndex],
                        ),                        
                      );
                    }),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    )
    
    :

    Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15.0),
            Text(
              'Información del Tren:  $tren',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(
                height: 20.0), // Espaciado entre el título y la tabla
            Expanded(
              child: StickyHeadersTable(
                columnsLength: headers.length,
                rowsLength: data.length,
                columnsTitleBuilder: (i) => _buildHeaderCell(headers[i]),
                rowsTitleBuilder: (i) => _buildRowHeaderCell(
                  '${i + 1}',
                  mostrarIcono: reglas[i].toString().trim() == 'F',
                  item: infoTrain[i],
                ),
                contentCellBuilder: (i, j) =>
                    _buildDataCell(data[j], i, reglas[j], infoTrain[j]),
                legendCell: Container(),
                cellDimensions: CellDimensions.variableColumnWidth(
                  columnWidths: List.generate(headers.length, (index) {
                    double screenWidth = MediaQuery.of(context).size.width;
                    double baseWidth = screenWidth / headers.length;

                    // anchos estaticos para columnas indicadas
                    if (headers[index] == 'Secuencia') {
                      return baseWidth * 0.7;
                    } else if (headers[index] == 'Unidad') {
                      return baseWidth * 0.9;
                    } else if (headers[index] == 'Estatus') {
                      return baseWidth * 0.6;
                    } else if (headers[index] == 'Tipo de Equipo') {
                      return baseWidth * 0.7;
                    } else if (headers[index] == 'Articulados') {
                      return baseWidth * 0.8;
                    } else if (headers[index] == 'Peso\nArticulado') {
                      return baseWidth * 0.7;
                    } else if (headers[index] == 'Peso\nBruto') {
                      return baseWidth * 0.6;
                    } else if (headers[index] == 'Longitud') {
                      return baseWidth * 0.6;
                    } else {
                      return baseWidth; // Distribución uniforme
                    }
                  }),
                  contentCellHeight: 60,
                  stickyLegendWidth: 0,
                  stickyLegendHeight: 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cabeceraTabla() {
    return BoxDecoration(
      border: Border(
        left: BorderSide(color: Colors.grey.shade400),
        right: BorderSide(color: Colors.grey.shade400),
        top: BorderSide(color: Colors.grey.shade400),
        bottom: BorderSide(color: Colors.grey.shade400),
      ),
      color: Colors.black,
    );
  }

  Widget _buildHeaderCell(String text) {
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isLaptop? 13.0 : 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRowHeaderCell(String text,
      {bool mostrarIcono = false, required Map<String, dynamic> item}) {
    return MouseRegion(
      cursor:
          mostrarIcono ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        child: Container(
          color: mostrarIcono ? Colors.red : Colors.black,
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: mostrarIcono ? Colors.red : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(List<String> rowData, int columnIndex, String regla,
      Map<String, dynamic> item) {
        final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    String text = rowData[columnIndex];
    bool esReglaF = regla == 'F';

    return GestureDetector(
      onTap: () {
        if (esReglaF) {
          _showRuleDetailsModal(context, item);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade500),
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (esReglaF && columnIndex == 0) // Solo en la columna "Secuencia"
              IconButton(
                icon: const Icon(Icons.warning_rounded, color: Colors.orange),
                tooltip: 'Ver detalles de reglas inválidas',
                onPressed: () {
                  _showRuleDetailsModal(context, item);
                },
              ),
            const SizedBox(height: 6.0),
            Text(
              text,
              style: TextStyle(
                fontSize: isLaptop? 11.0 : 15.0,
                color: esReglaF ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showRuleDetailsModal(BuildContext context, Map<String, dynamic> item) {
    final reglaProvider =
        Provider.of<ReglaIncumplidaProvider>(context, listen: false);
    final int idConsist = item['id'] is int
        ? item['id']
        : int.tryParse(item['id'].toString()) ?? 0;

    reglaProvider.mostrarReglaIncumplida(idConsist);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Detalles de la regla incumplida',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Secuencia: ${item['posicion']}',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 10),
              Text(
                'Unidad: ${item['unidad']}',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 10),
              Consumer<ReglaIncumplidaProvider>(
                builder: (context, provider, child) {
                  final regla = provider.reglasIncumplidas.firstWhere(
                    (regla) => regla.idConsist == idConsist,
                    orElse: () => ReglaIncumplida(
                      idConsist: 0,
                      regla: 'No encontrado',
                      descripcion: 'No se encontró la descripción',
                      idTren: '',
                      idValidacion: 0,
                      activo: false,
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Regla: ${regla.regla}',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Descripción: ${regla.descripcion}',
                          style: const TextStyle(fontSize: 18.0),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, color: Colors.red, size: 22.0),
                  SizedBox(width: 5.0),
                  Text(
                    'Cerrar',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
