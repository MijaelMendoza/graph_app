import 'dart:ui';

import 'package:flutter/material.dart';

class ModeloNodo {
  double x, y, r;
  Color color;
  String nombre;
  bool isSelected; // Nueva propiedad

  ModeloNodo(this.x, this.y, this.r, this.color, this.nombre, {this.isSelected = false});
}

class Conexion {
  ModeloNodo nodoInicio;
  ModeloNodo nodoFin;
  double peso;
  String tipo; // Puede ser "no-dirigido", "dirigido", "bidireccional"
  Color color; // Agregar este atributo si aún no existe

  Conexion(this.nodoInicio, this.nodoFin, this.peso, this.tipo, {this.color = Colors.black});
}
