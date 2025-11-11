// // networkiing_service.dart
// import 'dart:convert';
// import 'dart:developer' as developer;
// import 'package:http/http.dart' as http;

// class NetworkiingService {
//   static Future<Map<String, dynamic>> getonepost(String id) async {
//     final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/$id');

//     final response = await http.get(
//       url,
//       headers: {
//         // Cloudflare lets real browsers through
//         'User-Agent':
//             'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
//         'Accept': 'application/json',
//         'Accept-Language': 'en-US,en;q=0.9',
//       }
//     );
//     var decodedData = jsonDecode(response.body);

//     developer.log('Status: ${response.statusCode}');
//     developer.log('Body: ${decodedData.runtimeType.toString()}');

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body) as Map<String, dynamic>;
//     } else {
//       // Throw a readable error – the HTML is not JSON
//       throw Exception(
//           'Failed to load post – status ${response.statusCode}. '
//           'If you see HTML, Cloudflare blocked the request.');
//     }
//   }
// }