import 'dart:convert';
import 'package:flutter/services.dart';

class SROOffice {
  final String id;
  final String name;

  SROOffice({required this.id, required this.name});

  factory SROOffice.fromJson(Map<String, dynamic> json) {
    return SROOffice(
      id: json['id'],
      name: json['name'],
    );
  }
}

class LocationService {
  List<SROOffice>? _sroOffices;

  Future<List<SROOffice>> getAllSROs() async {
    if (_sroOffices != null) return _sroOffices!;

    final String jsonString = await rootBundle.loadString('assets/locations.json');
    final List<dynamic> data = jsonDecode(jsonString);
    
    // Flatten the structure - get all SROs from all "districts"
    final List<SROOffice> allSROs = [];
    for (var district in data) {
      final List<dynamic> sros = district['sros'];
      for (var sro in sros) {
        allSROs.add(SROOffice.fromJson(sro));
      }
    }
    
    // Sort alphabetically by name
    allSROs.sort((a, b) => a.name.compareTo(b.name));
    
    _sroOffices = allSROs;
    return _sroOffices!;
  }
}
