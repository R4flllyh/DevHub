import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/article_model.dart';

class NewsRemoteDataSource {
  // Base URL murni tanpa slash di ujung agar penggabungan URL konsisten
  final String _baseUrl = 'https://dev.to/api';

  // Method fetch artikel dengan default page = 1 dan per_page dikunci ke 20
  Future<List<ArticleModel>> getLatestArticles({
    int page = 1,
    String? query,
    String? tag,
  }) async {
    try {
      final Map<String, String> queryParameters = {
        'page': page.toString(),
        'per_page': '20',
      };

      // 💡 Priority 1: Jika ada tag eksplisit (misal dari TagArticlesPage)
      if (tag != null && tag.isNotEmpty) {
        queryParameters['tag'] = tag.toLowerCase().replaceAll(' ', '');
      }
      // 💡 Priority 2: Jika user mengetik di Search Bar
      else if (query != null && query.isNotEmpty) {
        // Ubah query search user menjadi tag parameter agar DEV.to memfilter artikelnya
        queryParameters['tag'] = query.toLowerCase().trim().replaceAll(' ', '');
      }

      final uri = Uri.https('dev.to', '/api/articles', queryParameters);

      // Cek di Debug Console log URL yang dipanggil
      print('FETCHING URL: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = jsonDecode(response.body);
        return decodedData.map((json) => ArticleModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load articles (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to Connect to the Server: $e');
    }
  }

  // New Method to GET Full Detail Article
  Future<String> getArticleContent(int id) async {
    try {
      // hit detail endpoint
      final response = await http.get(Uri.parse('$_baseUrl/articles/$id'));

      if (response.statusCode == 200) {
        // Karena detail hanya mengembalikan 1 objek (bukan List), kita gunakan Map
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        // Ambil data 'body_markdown' langsung dari JSON nya
        return decodedData['body_markdown'] ?? 'No Content Available';
      } else {
        throw Exception(
          'Failed to load article content (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to Connect to the Server');
    }
  }

  // Method for GET data comments
  Future<List<dynamic>> getArticleComments(int articleId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/comments?a_id=$articleId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
          'Failed to load Comment (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to Connect to the server');
    }
  }
}
