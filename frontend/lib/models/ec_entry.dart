import 'boundary_data.dart';

class ECEntry {
  final String docNumber;
  final String date;
  final String nature;
  final String parties;
  final String consideration;
  final BoundaryData boundaries;
  final String scheduleText;

  ECEntry({
    required this.docNumber,
    required this.date,
    required this.nature,
    required this.parties,
    required this.consideration,
    required this.boundaries,
    required this.scheduleText,
  });

  factory ECEntry.fromJson(Map<String, dynamic> json) {
    return ECEntry(
      docNumber: json['docNumber'] ?? '',
      date: json['docDate'] ?? '',
      nature: json['nature'] ?? '',
      parties: json['parties'] ?? '',
      consideration: json['consideration'] ?? '',
      scheduleText: json['scheduleText'] ?? '',
      // Ensure 'boundaries' exists in backend response for each entry, 
      // otherwise default to empty.
      boundaries: json['boundaries'] != null 
          ? BoundaryData.fromJson(json['boundaries']) 
          : BoundaryData(north: '-', south: '-', east: '-', west: '-'),
    );
  }
}
