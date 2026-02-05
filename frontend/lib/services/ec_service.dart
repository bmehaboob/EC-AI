import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/ec_entry.dart';

class ECService {
  Future<Map<String, dynamic>> startSearch({
    required String district,
    required String sro,
    required String docNumber,
    required String year,
  }) async {
    final url = Uri.parse(ApiConstants.startSearch);
    
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
      throw Exception('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchResults(String sessionId) async {
    final url = Uri.parse(ApiConstants.fetchResults);
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Transform the raw entries list into ECEntry objects if needed here, 
        // or just return data and let UI handle it. 
        // Returning raw data for flexible handling in Screens.
        return data; 
      } else {
        throw Exception('Failed to fetch results: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching results: $e');
    }
  }
}
