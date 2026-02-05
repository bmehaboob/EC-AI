class ApiConstants {
  // IMPORTANT: Update this based on where your backend is running
  // For local development: 'http://localhost:3000'
  // For Railway: Replace with your actual Railway URL
  static const String baseUrl = 'http://localhost:3000'; 
  
  static const String startSearch = '$baseUrl/api/ec/start-search';
  static const String fetchResults = '$baseUrl/api/ec/fetch-and-parse';
}
