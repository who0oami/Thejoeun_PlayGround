import 'package:flutter/material.dart';

class SystemStatus {
  const SystemStatus({
    required this.name,
    required this.description,
    required this.icon,
    required this.isHealthy,
  });

  final String name;
  final String description;
  final IconData icon;
  final bool isHealthy;
}
