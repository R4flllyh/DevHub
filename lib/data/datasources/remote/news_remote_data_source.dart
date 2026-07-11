import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/article_model.dart';

class NewsRemoteDataSource {
  // Base URL murni tanpa slash di ujung agar penggabungan URL konsisten
  final String _baseUrl = 'https://dev.to/api';

  // Method fetch artikel dengan default page = 1 dan per_page dikunci ke 20
  Future<List<ArticleModel>> getLatestArticles({int page = 1}) async {
    try {
      // Perbaikan 1: Gunakan objek 'http' sesuai alias import Anda
      // Perbaikan 2: Gabungkan _baseUrl dengan endpoint secara utuh menggunakan String Interpolation
      final response = await http.get(
        Uri.parse('$_baseUrl/articles?page=$page&per_page=20'),
      );

      // Check jika response status code adalah 200 (OK)
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
}
