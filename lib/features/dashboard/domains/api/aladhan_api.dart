import 'dart:convert';

import 'package:muslim_schedule/features/dashboard/domains/models/aladhan_model.dart';
import 'package:http/http.dart' as http;

class AladhanApi {
  final String baseUrl;
  AladhanApi({required this.baseUrl});

  Future<AladhanModel> fetchapi() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200){
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AladhanModel.fromJson(jsonResponse['data']['timings']);
      }else {
        throw Exception('Failed to load products: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchMoney: $e');
      throw Exception('Error: $e');
    }
  }
}

