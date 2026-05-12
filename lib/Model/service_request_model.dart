import 'dart:convert';
import 'package:flutter/material.dart';

class ServiceRequest {
  final int id;
  final String reference;
  final String serviceName;
  final String commune;
  final String status;
  final String salaryAmount; // Nom unique à utiliser partout
  final List<dynamic>? days; // Nullable pour éviter les erreurs d'invocation

  ServiceRequest({
    required this.id,
    required this.reference,
    required this.serviceName,
    required this.commune,
    required this.status,
    required this.salaryAmount,
    this.days,
  });
}