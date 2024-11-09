import 'package:flutter/material.dart';
import 'package:grafos/Models/modelos.dart';

void showAStarDialog(BuildContext context, List<ModeloNodo> vNodo,
    Function(ModeloNodo, ModeloNodo) onSearch) {
  ModeloNodo? nodoInicial;
  ModeloNodo? nodoMeta;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('Encontrar Camino con A*'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<ModeloNodo>(
                  hint: Text('Seleccionar Nodo Inicial'),
                  value: nodoInicial,
                  onChanged: (ModeloNodo? newValue) {
                    setDialogState(() {
                      nodoInicial = newValue;
                    });
                  },
                  items: vNodo
                      .map<DropdownMenuItem<ModeloNodo>>((ModeloNodo value) {
                    return DropdownMenuItem<ModeloNodo>(
                      value: value,
                      child: Text(value.nombre),
                    );
                  }).toList(),
                ),
                DropdownButton<ModeloNodo>(
                  hint: Text('Seleccionar Nodo Meta'),
                  value: nodoMeta,
                  onChanged: (ModeloNodo? newValue) {
                    setDialogState(() {
                      nodoMeta = newValue;
                    });
                  },
                  items: vNodo
                      .map<DropdownMenuItem<ModeloNodo>>((ModeloNodo value) {
                    return DropdownMenuItem<ModeloNodo>(
                      value: value,
                      child: Text(value.nombre),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (nodoInicial != null && nodoMeta != null) {
                    onSearch(
                        nodoInicial!, nodoMeta!); // Aseguramos que no sean null
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Buscar'),
              ),
            ],
          );
        },
      );
    },
  );
}

void showDijkstraDialog(BuildContext context, List<ModeloNodo> vNodo,
    Function(ModeloNodo, ModeloNodo, String) onSearch) {
  // Modificado para recibir el modo
  ModeloNodo? nodoInicial;
  ModeloNodo? nodoMeta;
  String modoBusqueda = 'Minimizar'; // Valor predeterminado

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('Encontrar Camino con Dijkstra'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<ModeloNodo>(
                  hint: Text('Seleccionar Nodo Inicial'),
                  value: nodoInicial,
                  onChanged: (ModeloNodo? newValue) {
                    setDialogState(() {
                      nodoInicial = newValue;
                    });
                  },
                  items: vNodo
                      .map<DropdownMenuItem<ModeloNodo>>((ModeloNodo value) {
                    return DropdownMenuItem<ModeloNodo>(
                      value: value,
                      child: Text(value.nombre),
                    );
                  }).toList(),
                ),
                DropdownButton<ModeloNodo>(
                  hint: Text('Seleccionar Nodo Meta'),
                  value: nodoMeta,
                  onChanged: (ModeloNodo? newValue) {
                    setDialogState(() {
                      nodoMeta = newValue;
                    });
                  },
                  items: vNodo
                      .map<DropdownMenuItem<ModeloNodo>>((ModeloNodo value) {
                    return DropdownMenuItem<ModeloNodo>(
                      value: value,
                      child: Text(value.nombre),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  value: modoBusqueda,
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      modoBusqueda = newValue!;
                    });
                  },
                  items: ['Minimizar', 'Maximizar']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (nodoInicial != null && nodoMeta != null) {
                    onSearch(nodoInicial!, nodoMeta!,
                        modoBusqueda); // Pasamos el modo de búsqueda
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Buscar'),
              ),
            ],
          );
        },
      );
    },
  );
}

void showEditNodeDialog(BuildContext context, ModeloNodo nodo,
    void Function(void Function()) setState) {
  final TextEditingController nombreController =
      TextEditingController(text: nodo.nombre);
  double nuevoRadio = nodo.r;
  Color nuevoColor = nodo.color;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('Modificar Nodo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre del nodo'),
                ),
                Text('Radio: ${nuevoRadio.toStringAsFixed(0)}'),
                Slider(
                  value: nuevoRadio,
                  min: 10,
                  max: 100,
                  divisions: 18,
                  label: nuevoRadio.toStringAsFixed(0),
                  onChanged: (double value) {
                    setDialogState(() {
                      nuevoRadio = value;
                    });
                  },
                ),
                Text('Color'),
                Wrap(
                  children: Colors.primaries.map((Color color) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          nuevoColor = color;
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          border: nuevoColor == color
                              ? Border.all(width: 2, color: Colors.black)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    nodo.nombre = nombreController.text;
                    nodo.r = nuevoRadio;
                    nodo.color = nuevoColor;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Guardar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    },
  );
}

void showEditConexionDialog(BuildContext context, Conexion conexion,
    void Function(void Function()) setState) {
  final TextEditingController pesoController =
      TextEditingController(text: conexion.peso.toStringAsFixed(1));
  String tipoConexion = conexion.tipo;
  Color nuevoColor = conexion.color;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('Editar Conexión'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pesoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Peso'),
                ),
                Text('Tipo de Conexión'),
                DropdownButton<String>(
                  value: tipoConexion,
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      tipoConexion = newValue!;
                    });
                  },
                  items: <String>['no-dirigido', 'dirigido', 'bidireccional']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Text('Color de la Conexión'),
                Wrap(
                  children: Colors.primaries.map((Color color) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          nuevoColor = color;
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          border: nuevoColor == color
                              ? Border.all(width: 2, color: Colors.black)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    conexion.peso =
                        double.tryParse(pesoController.text) ?? conexion.peso;
                    conexion.tipo = tipoConexion;
                    conexion.color = nuevoColor;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}

// lib/modals.dart
void createConnection(BuildContext context, Function(Conexion) addConexion,
    ModeloNodo? nodoInicio, ModeloNodo? nodoFin) {
  String tipoConexion = 'dirigido';
  final TextEditingController pesoController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('Crear Conexión'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: tipoConexion,
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      tipoConexion = newValue!;
                    });
                  },
                  items: <String>['no-dirigido', 'dirigido', 'bidireccional']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: pesoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Peso'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  double peso = double.tryParse(pesoController.text) ?? 1.0;
                  if (nodoInicio != null && nodoFin != null) {
                    Conexion nuevaConexion = Conexion(
                      nodoInicio,
                      nodoFin,
                      peso,
                      tipoConexion,
                    );
                    addConexion(nuevaConexion);
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}
