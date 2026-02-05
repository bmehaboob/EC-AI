import 'dart:convert';
import 'package:flutter/services.dart';

class District {
  final String id;
  final String name;
  final List<SRO> sros;

  District({required this.id, required this.name, required this.sros});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      sros: (json['sros'] as List).map((s) => SRO.fromJson(s)).toList(),
    );
  }
}

class SRO {
  final String id;
  final String name;

  SRO({required this.id, required this.name});

  factory SRO.fromJson(Map<String, dynamic> json) {
    return SRO(
      id: json['id'],
      name: json['name'],
    );
  }
}

class LocationService {
  List<District>? _districts;

  Future<List<District>> getDistricts() async {
    if (_districts != null) return _districts!;

    final String jsonString = await rootBundle.loadString('assets/locations.json');
    final List<dynamic> data = jsonDecode(jsonString);
    _districts = data.map((d) => District.fromJson(d)).toList();
    return _districts!;
  }

  List<SRO> getSROsForDistrict(String districtId) {
    if (_districts == null) return [];
    final district = _districts!.firstWhere(
      (d) => d.id == districtId,
      orElse: () => District(id: '', name: '', sros: []),
    );
    return district.sros;
  }
}
