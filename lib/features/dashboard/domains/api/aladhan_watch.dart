import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:muslim_schedule/features/dashboard/domains/models/aladhan_modelwatch.dart';

class AladhanApiday {
  final String baseUrl;
  AladhanApiday({required this.baseUrl});

  Future<AladhanModelday> fetchapiwatch() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200){
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AladhanModelday.fromJson(jsonResponse['data']['date']['hijri']);
      }else {
        throw Exception('Failed to load products: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchData Watch: $e');
      throw Exception('Error: $e');
    }
  }
}

