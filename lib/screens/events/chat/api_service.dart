import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, String>> fetchSupabaseConfig() async {
  final response = await http.get(Uri.parse('https://8bzqcx5t-8000.inc1.devtunnels.ms/supabase-config'));

  try {
    final data = json.decode(response.body);
    print('Supabase config loaded: $data');
    return 
      data;
      // 'url': data['url'],
      // 'public_key': data['public_key'],
    
  } catch (e) {
    print('Failed to load Supabase config $e');
    throw Exception('Failed to load Supabase config');
  }
}


Future<void> initializeSupabase() async {
  final config = await fetchSupabaseConfig();

  await Supabase.initialize(
    url: config['url']!,
    anonKey: config['public_key']!,
  );
}
