import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grafos/UI/dibujos.dart';
import 'package:grafos/UI/menu_drawer.dart';
import 'package:grafos/Models/modelos.dart';
import 'package:grafos/Algoritmos/dijkstra.dart';
import 'package:grafos/utils/helpers.dart';
import 'package:grafos/UI/modals.dart';
import 'package:universal_html/html.dart' as html;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  List<ModeloNodo> vNodo = [];
  List<Conexion> conexiones = [];
  int idNodo = 1;
  int modo = -1;
  ModeloNodo? nodoSeleccionado1;
  ModeloNodo? nodoSeleccionado2;
  ModeloNodo? nodoParaMover;
  Conexion? conexionSeleccionada;
  List<Conexion> shortestPath = [];
  late AnimationController _animationController;
  double animationProgress = 0.0;
  bool shouldAnimate = false;
  List<ModeloNodo> selectedNodes = []; // Nodos seleccionados
  Rect? selectionRect; // Rectángulo de selección
  Offset? dragStart; // Inicio de la selección
  Offset?
      initialDragOffset; // Posición inicial del arrastre en el modo de selección múltiple
  int currentSegmentIndex = 0;

  final DijkstraPathfinding dijkstra = DijkstraPathfinding();

  @override
  void initState() {
    super.initState();
    _setupAnimationController();
    _setupDijkstraAnimationListener();
  }

  void _setupAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        if (shouldAnimate) {
          setState(() {
            animationProgress = _animationController.value;
          });
        }
      });
  }

  void _setupDijkstraAnimationListener() {
    dijkstra.pathUpdates.listen((updatedPath) {
      if (updatedPath.isEmpty) {
        shouldAnimate = true;
        _animateLineDrawing();
      } else {
        shouldAnimate = false;
        setState(() {
          shortestPath = updatedPath;
        });
      }
    });
  }

  void _animateLineDrawing() async {
    for (currentSegmentIndex = 0;
        currentSegmentIndex < shortestPath.length;
        currentSegmentIndex++) {
      setState(() {
        animationProgress = 0.0; // Reinicia progreso para cada segmento
      });

      _animationController.reset();
      await _animationController
          .forward()
          .orCancel; // Avanza animación del segmento

      setState(() {
        animationProgress = 1.0; // Completa el progreso del segmento actual
      });

      await Future.delayed(
          Duration(milliseconds: 100)); // Pausa entre segmentos
    }

    setState(() {
      shouldAnimate = false; // Finaliza la animación
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _clearConnections() {
    setState(() {
      conexiones.clear();
    });
  }

  void _clearCanvas() {
    setState(() {
      vNodo.clear();
      conexiones.clear();
    });
  }

  void _clearAlgorithm() {
    setState(() {
      for (var nodo in vNodo) {
        nodo.isSelected = false; // Quitar selección si está activa
        nodo.color =
            Colors.purple; // Restablecer al color original o el que prefieras
      }
      shortestPath.clear(); // Limpiar el camino crítico si es necesario
    });
  }

  void _exitApp() {
    Navigator.of(context).pop(); // Cierra el Drawer
    Future.delayed(Duration(milliseconds: 200), () {
      if (kIsWeb) {
        // En la web, redirigir a una página en blanco
        html.window.location.href = "google.com";
      } else if (Platform.isAndroid || Platform.isIOS) {
        // En dispositivos móviles, cierra la aplicación
        SystemNavigator.pop();
      } else {
        // En otras plataformas, usa exit(0) como alternativa
        exit(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: MenuDrawer(
          onClearCanvas: _clearCanvas,
          onClearConnections: _clearConnections,
          onClearAlgorithm: _clearAlgorithm, // Pasa el nuevo callback aquí
          onExit: _exitApp,
        ),
        appBar: AppBar(
          title: Text('App de Grafos'),
          backgroundColor: Colors.teal.shade800,
        ),
        body: Stack(
          children: [
            modo == 5
                ? InteractiveViewer(
                    boundaryMargin: EdgeInsets.all(20.0),
                    minScale: 0.001,
                    maxScale: 3.0,
                    child: _buildCanvas(),
                  )
                : _buildCanvas(),
            GestureDetector(
              onPanDown: (desp) => _handlePanDown(desp),
              onPanUpdate: (details) => _handlePanUpdate(details),
              onPanEnd: (details) => _handlePanEnd(),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.teal.shade900,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModeButton(Icons.add, 1),
              _buildModeButton(Icons.delete, 2),
              _buildModeButton(Icons.edit, 3),
              _buildModeButton(Icons.link, 4),
              _buildModeButton(Icons.open_with, 5),
              _buildModeButton(
                  Icons.select_all, 6), // Modo de selección múltiple
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDijkstraDialog(context, vNodo,
              (nodoInicial, nodoMeta, modoBusqueda) {
            _startDijkstraAnimation(nodoInicial, nodoMeta, modoBusqueda);
          }),
          child: Text("Dijkstra"),
          backgroundColor: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return Stack(
      children: [
        CustomPaint(
          painter: DibujaNodo(vNodo, conexiones, shortestPath,
              animationProgress, shouldAnimate, currentSegmentIndex),
          child: Container(),
        ),
        if (modo == 6 &&
            selectionRect !=
                null) // Mostrar siempre que `selectionRect` esté definido
          Positioned.fromRect(
            rect: selectionRect!,
            child: Container(
              color: Colors.blue.withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModeButton(IconData icon, int selectedMode) {
    return CircleAvatar(
      backgroundColor: (modo == selectedMode) ? Colors.white : Colors.teal,
      child: IconButton(
        onPressed: () {
          setState(() {
            modo = selectedMode;
          });
        },
        icon: Icon(icon),
      ),
    );
  }

  void _handlePanDown(DragDownDetails desp) {
    if (modo == 6) {
      // Verificar si el toque está dentro del rectángulo de selección existente
      if (selectionRect != null &&
          selectionRect!.contains(desp.localPosition)) {
        // Iniciar arrastre del rectángulo de selección
        initialDragOffset = desp.localPosition;
      } else {
        // Si el toque está fuera, iniciar un nuevo rectángulo de selección
        dragStart = desp.localPosition;
        initialDragOffset = desp.localPosition;
        setState(() {
          selectedNodes.clear();
          selectionRect = null;
        });
      }
    } else if (modo == 1) {
      // Modo agregar nodo
      setState(() {
        vNodo.add(ModeloNodo(
          desp.localPosition.dx,
          desp.localPosition.dy,
          40,
          Colors.purple,
          vNodo.length.toString(),
        ));
        idNodo++;
      });
    } else if (modo == 2 || modo == 3) {
      // Modo eliminar o modificar
      bool nodoEncontrado = false;
      for (var nodo in vNodo) {
        if (distanciaEntrePuntos(
                nodo.x, nodo.y, desp.localPosition.dx, desp.localPosition.dy) <
            nodo.r) {
          nodoEncontrado = true;
          if (modo == 2) {
            // Eliminar nodo y conexiones asociadas
            setState(() {
              vNodo.remove(nodo);
              conexiones.removeWhere(
                  (c) => c.nodoInicio == nodo || c.nodoFin == nodo);
            });
          } else if (modo == 3) {
            _showEditNodeDialog(nodo);
          }
          break;
        }
      }
      if (!nodoEncontrado) {
        for (var conexion in conexiones) {
          if (estaCercaDeConexion(desp.localPosition, conexion)) {
            if (modo == 2) {
              setState(() {
                conexiones.remove(conexion);
              });
            } else if (modo == 3) {
              _showEditConexionDialog(conexion);
            }
            break;
          }
        }
      }
    } else if (modo == 4) {
      for (var nodo in vNodo) {
        if (distanciaEntrePuntos(
                nodo.x, nodo.y, desp.localPosition.dx, desp.localPosition.dy) <
            nodo.r) {
          setState(() {
            if (nodoSeleccionado1 == null) {
              nodoSeleccionado1 = nodo;
              nodo.isSelected = true; // Cambiar a verde
            } else if (nodoSeleccionado2 == null && nodo != nodoSeleccionado1) {
              nodoSeleccionado2 = nodo;
              nodo.isSelected = true; // Cambiar a verde
              _crearConexion();
            }
          });
          break;
        }
      }
    } else if (modo == 5) {
      for (var nodo in vNodo) {
        if (distanciaEntrePuntos(
                nodo.x, nodo.y, desp.localPosition.dx, desp.localPosition.dy) <
            nodo.r) {
          setState(() {
            nodoParaMover = nodo;
          });
          break;
        }
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (modo == 6 && dragStart != null) {
      setState(() {
        final dragCurrent = details.localPosition;
        selectionRect = Rect.fromPoints(dragStart!, dragCurrent);

        // Actualiza los nodos seleccionados dentro del rectángulo de selección
        selectedNodes = vNodo.where((nodo) {
          final nodeRect =
              Rect.fromCircle(center: Offset(nodo.x, nodo.y), radius: nodo.r);
          return selectionRect!.overlaps(nodeRect);
        }).toList();
      });
    } else if (modo == 6 &&
        selectedNodes.isNotEmpty &&
        initialDragOffset != null) {
      // Mover nodos seleccionados al arrastrar el rectángulo de selección
      final dx = details.localPosition.dx - initialDragOffset!.dx;
      final dy = details.localPosition.dy - initialDragOffset!.dy;

      setState(() {
        for (var nodo in selectedNodes) {
          nodo.x += dx;
          nodo.y += dy;
        }

        // Mover el rectángulo de selección
        selectionRect = selectionRect!.shift(Offset(dx, dy));
        initialDragOffset =
            details.localPosition; // Actualizar para el próximo movimiento
      });
    } else if (nodoParaMover != null && modo == 5) {
      // Mover nodo individual
      setState(() {
        nodoParaMover!.x += details.delta.dx;
        nodoParaMover!.y += details.delta.dy;
      });
    }
  }

  void _handlePanEnd() {
    setState(() {
      dragStart = null;
      initialDragOffset = null;
      // `selectionRect` ya no se establece en `null` para que permanezca visible
    });
  }

  void _showEditNodeDialog(ModeloNodo nodo) {
    showEditNodeDialog(context, nodo, setState);
  }

  void _showEditConexionDialog(Conexion conexion) {
    showEditConexionDialog(context, conexion, setState);
  }

  void _crearConexion() {
    createConnection(context, (newConexion) {
      setState(() {
        if (nodoSeleccionado1 != null && nodoSeleccionado2 != null) {
          conexiones.add(newConexion);

          // Restaurar el color original de los nodos seleccionados
          nodoSeleccionado1!.isSelected = false;
          nodoSeleccionado2!.isSelected = false;

          nodoSeleccionado1 = null;
          nodoSeleccionado2 = null;
        }
      });
    }, nodoSeleccionado1, nodoSeleccionado2);
  }

  void _startDijkstraAnimation(
      ModeloNodo startNode, ModeloNodo goalNode, String modoBusqueda) {
    shortestPath = [];
    dijkstra.findShortestPathAnimated(
        startNode, goalNode, conexiones, modoBusqueda);
  }
}
