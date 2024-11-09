// lib/helpers.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grafos/Models/modelos.dart';

double distanciaEntrePuntos(double x1, double y1, double x2, double y2) {
  return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}

bool estaCercaDeConexion(Offset punto, Conexion conexion) {
  final p1 = Offset(conexion.nodoInicio.x, conexion.nodoInicio.y);
  final p2 = Offset(conexion.nodoFin.x, conexion.nodoFin.y);
  final control = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2 - 50);
  const double umbral = 10.0;
  for (double t = 0; t <= 1.0; t += 0.05) {
    Offset puntoEnCurva = calcularPuntoEnBezier(t, p1, control, p2);
    if ((punto - puntoEnCurva).distance < umbral) {
      return true;
    }
  }
  return false;
}

Offset calcularPuntoEnBezier(double t, Offset p0, Offset p1, Offset p2) {
  double x = pow(1 - t, 2) * p0.dx + 2 * (1 - t) * t * p1.dx + pow(t, 2) * p2.dx;
  double y = pow(1 - t, 2) * p0.dy + 2 * (1 - t) * t * p1.dy + pow(t, 2) * p2.dy;
  return Offset(x, y);
}
