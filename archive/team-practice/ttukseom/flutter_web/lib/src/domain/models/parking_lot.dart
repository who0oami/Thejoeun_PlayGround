import 'package:flutter/material.dart';

class ParkingLot {
  const ParkingLot({
    required this.name,
    required this.occupied,
    required this.available,
    required this.capacity,
    required this.latitude,
    required this.longitude,
    required this.statusLabel,
    required this.statusColor,
    required this.progressColor,
  });

  final String name;
  final int occupied;
  final int available;
  final int capacity;
  final double latitude;
  final double longitude;
  final String statusLabel;
  final Color statusColor;
  final Color progressColor;

  double get occupancyRate => capacity == 0 ? 0 : occupied / capacity;
  int get remaining => available;
}
