import 'package:flutter/material.dart';
import 'package:gestion_cliente/screens/servicios/academia_page.dart';
import 'package:gestion_cliente/screens/servicios/fisioterapia_page.dart';
import 'package:gestion_cliente/screens/servicios/gimnasio_page.dart';
import 'package:gestion_cliente/screens/servicios/peluqueria_page.dart';
import 'package:gestion_cliente/screens/servicios/yoga_page.dart';

// Centraliza la configuración de servicios: páginas e iconos por tipo de negocio

class ServiceFactory {
  static final Map<String, Widget Function(String uid, String nombre)> pages = {
    'Gimnasio': (uid, nombre) =>
        GimnasioPage(userId: uid, negocio: nombre),

    'Yoga': (uid, nombre) =>
        YogaPage(userId: uid, negocio: nombre),

    'Peluqueria': (uid, nombre) =>
        PeluqueriaPage(userId: uid, negocio: nombre),

    'Fisioterapia': (uid, nombre) =>
        FisioterapiaPage(userId: uid, negocio: nombre),

    'Academia': (uid, nombre) =>
        AcademiaPage(userId: uid, negocio: nombre),
  };
    static final icons = {
    'Gimnasio': Icons.fitness_center,
    'Yoga': Icons.self_improvement,
    'Peluqueria': Icons.content_cut,
    'Fisioterapia': Icons.health_and_safety,
    'Academia': Icons.school,
  };
}