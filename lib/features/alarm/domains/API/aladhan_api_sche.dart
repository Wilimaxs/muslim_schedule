import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:muslim_schedule/features/alarm/domains/models/aladhan_model_alarm.dart';

class AladhanApialarm {
  final String baseUrl;
  AladhanApialarm({required this.baseUrl});

  Future<AladhanModelalarm> fetchapialarm() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200){
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AladhanModelalarm.fromJson(jsonResponse['data']['timings']);
      }else {
        throw Exception('Failed to load products: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchMoney: $e');
      throw Exception('Error: $e');
    }
  }
}

