import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class ChildLocation {
  final double lat;
  final double lng;
  const ChildLocation({required this.lat, required this.lng});

  factory ChildLocation.fromJson(Map<String, dynamic> json) {
    return ChildLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class LocationService {
  static Future<ChildLocation?> fetchLocation(int childId) async {
    try {
      final uri = Uri.parse('$kBaseUrl/location/$childId');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ChildLocation.fromJson(json);
      } else {
        print(
            '[LocationService] HTTP ${response.statusCode} for child $childId');
        return null;
      }
    } catch (e) {
      print('[LocationService] Error fetching location for child $childId: $e');
      return null;
    }
  }
}
