import 'dart:convert';

import 'package:http/http.dart' as http;

class MandiRateService {
  static const _baseUrl = 'https://api.data.gov.in/resource';
  static const _resourceId = '9ef84268-d588-465a-a308-a864a43d0070';

  Future<double> fetchRate({
    required String cropName,
    required String location,
    String apiKey = 'demo',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$_resourceId?api-key=$apiKey&format=json&limit=1'
      '&filters[commodity]=$cropName&filters[district]=$location',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return 0;
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final records = json['records'] as List<dynamic>? ?? [];
    if (records.isEmpty) {
      return 0;
    }
    final record = records.first as Map<String, dynamic>;
    final modal = record['modal_price']?.toString() ?? '0';
    return double.tryParse(modal) ?? 0;
  }
}
