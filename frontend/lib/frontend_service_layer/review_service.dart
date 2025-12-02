import "package:dio/dio.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:virtour_frontend/frontend_service_layer/service_exception_handler.dart";

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  late final Dio dio;
  final String _baseUrl = UserInfo().tunnelUrl;
  final String apiKey = 'AIzaSyD77qzUuF6jTKP86pjGg4h5-EP0NW2Keik';

  factory ReviewService() {
    return _instance;
  }

  ReviewService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<List<Review>> getReviews(String placeName) async {
    try {
      final prompt =
          'Provide a list of reviews for the place with name $placeName in JSON format. The JSON object should have these fields: int statusCode, data: { String username, String id, String content, int rating, String date (formatted according to flutter DateTime format)}. The response should be a JSON array of review objects.';

      final response = await dio.post('$_baseUrl/api/ai/send-prompt', data: {
        'prompt': prompt,
      });
      final body = response.data as Map<String, dynamic>;
      if (response.statusCode == 200) {
        ;
        final reviewsData = body['data'] ?? [];
        return reviewsData
            .map<Review>((json) => Review.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to generate reviews: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServiceExceptionHandler.handleDioError(e);
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }
}
