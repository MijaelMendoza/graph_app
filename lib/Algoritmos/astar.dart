import 'package:grafos/Models/modelos.dart';

class AStarPathfinding {
  List<Conexion> findShortestPath(
      ModeloNodo start, ModeloNodo goal, List<Conexion> conexiones) {
    Map<ModeloNodo, ModeloNodo?> cameFrom = {};
    Map<ModeloNodo, double> gScore = {start: 0.0};
    Map<ModeloNodo, double> fScore = {start: _heuristic(start, goal)};
    List<ModeloNodo> openSet = [start];

    while (openSet.isNotEmpty) {
      // Ordenar para encontrar el nodo con el menor fScore
      openSet.sort((a, b) => (fScore[a] ?? double.infinity).compareTo(fScore[b] ?? double.infinity));
      ModeloNodo current = openSet.removeAt(0);

      if (current == goal) {
        return _reconstructPath(cameFrom, current, conexiones);
      }

      for (var conexion in conexiones) {
        ModeloNodo? neighbor;
        double connectionWeight = conexion.peso; // Usar el peso como double

        // Solo considerar grafos dirigidos: de nodoInicio a nodoFin
        if (conexion.nodoInicio == current) {
          neighbor = conexion.nodoFin;
        }

        if (neighbor != null) {
          // gScore = costo desde el nodo inicial hasta el nodo vecino
          double tentativeGScore = (gScore[current] ?? double.infinity) + connectionWeight;

          // Si encontramos un camino más corto al vecino, lo registramos
          if (tentativeGScore < (gScore[neighbor] ?? double.infinity)) {
            cameFrom[neighbor] = current;
            gScore[neighbor] = tentativeGScore;
            fScore[neighbor] = gScore[neighbor]!; // No usar heurística adicional

            // Agregar vecino a la lista abierta si no está ya presente
            if (!openSet.contains(neighbor)) {
              openSet.add(neighbor);
            }
          }
        }
      }
    }

    // Retornar una lista vacía si no se encuentra el camino
    return [];
  }

  double _heuristic(ModeloNodo a, ModeloNodo b) {
    // Usar heurística de 0 para considerar solo pesos de las conexiones
    return 0;
  }

  List<Conexion> _reconstructPath(
      Map<ModeloNodo, ModeloNodo?> cameFrom, ModeloNodo current, List<Conexion> conexiones) {
    List<Conexion> path = [];
    while (cameFrom.containsKey(current) && cameFrom[current] != null) {
      ModeloNodo prev = cameFrom[current]!;
      // Buscar la conexión dirigida que corresponda
      Conexion conexion = conexiones.firstWhere((c) =>
          c.nodoInicio == prev && c.nodoFin == current);
      path.insert(0, conexion);
      current = prev;
    }
    return path;
  }
}
