import 'package:flutter/material.dart';
import 'package:grafos/Models/modelos.dart';
import 'dart:math';

class DibujaNodo extends CustomPainter {
  List<ModeloNodo> vNodo;
  List<Conexion> conexiones;
  List<Conexion> shortestPath;
  double animationProgress;
  bool shouldAnimate;
  int currentSegmentIndex; // Índice del segmento actual para animación

  DibujaNodo(this.vNodo, this.conexiones, this.shortestPath,
      this.animationProgress, this.shouldAnimate, this.currentSegmentIndex);

  @override
  void paint(Canvas canvas, Size size) {
    Paint pincel = Paint()..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Calcular nodos críticos en función de shortestPath
    Set<ModeloNodo> criticalNodes = shortestPath
        .expand((conexion) => [conexion.nodoInicio, conexion.nodoFin])
        .toSet();

    // Dibujar los nodos
    for (var ele in vNodo) {
      // Pintar de rojo si es un nodo crítico
      pincel.color = ele.isSelected
          ? Colors.green
          : (criticalNodes.contains(ele) ? Colors.red : ele.color);
      canvas.drawCircle(Offset(ele.x, ele.y), ele.r, pincel);

      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: ele.r / 3,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(
        text: ele.nombre,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: double.infinity,
      );
      final offset = Offset(
        ele.x - (textPainter.width / 2),
        ele.y - (textPainter.height / 2),
      );
      textPainter.paint(canvas, offset);
    }

    // Dibujar las conexiones
    for (int i = 0; i < conexiones.length; i++) {
      final conexion = conexiones[i];
      final nodoInicio = conexion.nodoInicio;
      final nodoFinal = conexion.nodoFin;
      final startPoint = _calculateEdgePoint(
          nodoInicio.x, nodoInicio.y, nodoFinal.x, nodoFinal.y, nodoInicio.r);
      final endPoint = _calculateEdgePoint(
          nodoFinal.x, nodoFinal.y, nodoInicio.x, nodoInicio.y, nodoFinal.r);

      Paint paintConexion = Paint()
        ..color = shortestPath.contains(conexion) ? Colors.red : conexion.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      if (shortestPath.contains(conexion) && shouldAnimate) {
        if (i == currentSegmentIndex) {
          _drawProgressiveCurve(canvas, startPoint, endPoint, paintConexion);
        } else if (i < currentSegmentIndex) {
          _drawCompleteCurve(canvas, startPoint, endPoint, paintConexion);
        }
      } else {
        _drawCompleteCurve(canvas, startPoint, endPoint, paintConexion);
      }

      if (conexion.tipo == 'dirigido') {
        _drawArrow(canvas, paintConexion, startPoint, endPoint);
      } else if (conexion.tipo == 'bidireccional') {
        _drawArrow(canvas, paintConexion, startPoint, endPoint);
        _drawArrow(canvas, paintConexion, endPoint, startPoint);
      }

      // Dibujar el peso de la conexión en el punto medio
      final midPoint = Offset(
          (startPoint.dx + endPoint.dx) / 2, (startPoint.dy + endPoint.dy) / 2);
      textPainter.text = TextSpan(
        text: conexion.peso.toStringAsFixed(1),
        style: TextStyle(color: Colors.lightBlueAccent.shade700, fontSize: 14),
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(midPoint.dx - textPainter.width / 2,
              midPoint.dy - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  Offset _calculateEdgePoint(
      double x1, double y1, double x2, double y2, double radius) {
    double angle = atan2(y2 - y1, x2 - x1);
    return Offset(x1 + cos(angle) * radius, y1 + sin(angle) * radius);
  }

  void _drawCompleteCurve(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    final controlPoint =
        Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2 - 50);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  void _drawProgressiveCurve(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    final controlPoint =
        Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2 - 50);

    Path path = Path()..moveTo(start.dx, start.dy);
    double progressX = start.dx + (end.dx - start.dx) * animationProgress;
    double progressY = start.dy + (end.dy - start.dy) * animationProgress;

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, progressX, progressY);

    canvas.drawPath(path, paint);
  }

  void _drawArrow(Canvas canvas, Paint paint, Offset start, Offset end) {
    const double arrowSize = 10.0;
    const double arrowAngle = pi / 6;

    double angle = atan2(end.dy - start.dy, end.dx - start.dx);

    Offset arrowPoint1 = Offset(
      end.dx - arrowSize * cos(angle - arrowAngle),
      end.dy - arrowSize * sin(angle - arrowAngle),
    );

    Offset arrowPoint2 = Offset(
      end.dx - arrowSize * cos(angle + arrowAngle),
      end.dy - arrowSize * sin(angle + arrowAngle),
    );

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy);

    canvas.drawPath(arrowPath, paint);
  }
}
