# Flutter Integration Guide

Use this guide to connect your Flutter website to the EC Search Backend.

## 1. Add Dependencies
Add `http` package to your `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
```

## 2. Create API Service
Create a new file `lib/services/ec_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ECService {
  // Your Railway Backend URL
  static const String baseUrl = 'https://ec-search-production.up.railway.app'; // Replace with your actual domain

  Future<Map<String, dynamic>> startSearch({
    required String district,
    required String sro,
    required String docNumber,
    required String year,
  }) async {
    final url = Uri.parse('$baseUrl/api/ec/start-search');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'district': district,
          'sro': sro,
          'docNumber': docNumber,
          'year': year,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to start search: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> fetchResults(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/ec/fetch-and-parse');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch results: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching results: $e');
    }
  }
}
```

## 3. Usage in Widget
Example of how to call it:

```dart
final ecService = ECService();

// 1. Start Search
final result = await ecService.startSearch(
  district: 'Visakhapatnam',
  sro: 'Anakapalli',
  docNumber: '1234',
  year: '2023'
);

// Get Session ID
String sessionId = result['sessionId'];

// ... Wait for user to solve CAPTCHA (if using manual flow) ...

// 2. Fetch Results
final ecData = await ecService.fetchResults(sessionId);
print(ecData);
```
