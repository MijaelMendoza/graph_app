import 'package:grafos/Models/modelos.dart';
import 'package:collection/collection.dart';
import 'dart:async';

class DijkstraPathfinding {
  StreamController<List<Conexion>> _controller = StreamController.broadcast();
  StreamController<List<ModeloNodo>> _nodesController = StreamController.broadcast();

  Stream<List<Conexion>> get pathUpdates => _controller.stream;
  Stream<List<ModeloNodo>> get criticalNodes => _nodesController.stream;

  void findShortestPathAnimated(
      ModeloNodo start, ModeloNodo goal, List<Conexion> conexiones, String modoBusqueda) async {
    
    if (conexiones.any((c) => c.peso < 0)) {
      throw ArgumentError('Dijkstra no soporta pesos negativos.');
    }

    Map<ModeloNodo, double> distances = {};
    Map<ModeloNodo, ModeloNodo?> previousNodes = {};
    Set<ModeloNodo> inQueue = {};
    PriorityQueue<ModeloNodo> queue;

    queue = PriorityQueue((a, b) {
      return (distances[a] ?? double.infinity)
          .compareTo(distances[b] ?? double.infinity) * (modoBusqueda == 'Minimizar' ? 1 : -1);
    });

    for (var nodo in conexiones.expand((c) => [c.nodoInicio, c.nodoFin])) {
      distances[nodo] = (modoBusqueda == 'Minimizar') ? double.infinity : -double.infinity;
    }
    distances[start] = 0;
    queue.add(start);
    inQueue.add(start);

    while (queue.isNotEmpty) {
      ModeloNodo current = queue.removeFirst();
      inQueue.remove(current);

      if (current == goal) {
        List<Conexion> path = _reconstructPath(previousNodes, current, conexiones);
        List<ModeloNodo> criticalNodesList = _getPathNodes(path);
        _controller.add(path);
        await Future.delayed(Duration(milliseconds: 500));
        _controller.add([]);
        _nodesController.add(criticalNodesList);
        return;
      }

      for (var conexion in conexiones) {
        if (conexion.nodoInicio == current) {
          ModeloNodo neighbor = conexion.nodoFin;
          double pesoConexion = conexion.peso;
          double newDist = distances[current]! + pesoConexion;

          if ((modoBusqueda == 'Minimizar' && newDist < distances[neighbor]!) ||
              (modoBusqueda != 'Minimizar' && newDist > distances[neighbor]!)) {
            distances[neighbor] = newDist;
            previousNodes[neighbor] = current;

            if (!inQueue.contains(neighbor)) {
              queue.add(neighbor);
              inQueue.add(neighbor);
            }
          }
        }
      }

      List<Conexion> partialPath = _reconstructPath(previousNodes, current, conexiones);
      //_controller.add(partialPath);
      await Future.delayed(Duration(milliseconds: 50));
    }

    _controller.close();
    _nodesController.close();
  }

  List<Conexion> _reconstructPath(Map<ModeloNodo, ModeloNodo?> previousNodes,
      ModeloNodo current, List<Conexion> conexiones) {
    List<Conexion> path = [];
    while (previousNodes.containsKey(current) && previousNodes[current] != null) {
      ModeloNodo prev = previousNodes[current]!;
      Conexion conexion = conexiones.firstWhere((c) => c.nodoInicio == prev && c.nodoFin == current);
      path.insert(0, conexion);
      current = prev;
    }
    return path;
  }

  List<ModeloNodo> _getPathNodes(List<Conexion> path) {
    final Set<ModeloNodo> nodes = {};
    for (var conexion in path) {
      nodes.add(conexion.nodoInicio);
      nodes.add(conexion.nodoFin);
    }
    return nodes.toList();
  }
}


