class BoundaryData {
  final String north;
  final String south;
  final String east;
  final String west;
  final double confidence;

  BoundaryData({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    this.confidence = 0.0,
  });

  factory BoundaryData.fromJson(Map<String, dynamic> json) {
    return BoundaryData(
      north: json['north'] ?? 'Not specified',
      south: json['south'] ?? 'Not specified',
      east: json['east'] ?? 'Not specified',
      west: json['west'] ?? 'Not specified',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}
