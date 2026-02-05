class ApiConstants {
  // Use localhost for local dev usually, or the railway URL if testing prod directly.
  // For web, localhost points to the browser's machine.
  // If running backend locally: 'http://localhost:3000'
  // If using Railway: 'https://ec-ai-production.up.railway.app'
  static const String baseUrl = 'https://ec-search-production.up.railway.app'; 
  
  static const String startSearch = '$baseUrl/api/ec/start-search';
  static const String fetchResults = '$baseUrl/api/ec/fetch-and-parse';
}
