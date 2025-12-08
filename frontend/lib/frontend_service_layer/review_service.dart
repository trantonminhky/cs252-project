import "package:dio/dio.dart";
import "package:virtour_frontend/constants/userinfo.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:virtour_frontend/frontend_service_layer/service_exception_handler.dart";

class ReviewService {
  late final Dio dio;
  final String _baseUrl = UserInfo.tunnelUrl;
  final String _token;

  ReviewService(this._token) {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      ),
    );
  }

  Future<List<Review>> getReviews(String placeName) async {
    try {
      final response =
          await dio.post('$_baseUrl/api/ai/generate-reviews', data: {
        'place': placeName,
      });
      final body = response.data as Map<String, dynamic>;
      if (response.statusCode == 200) {
        final reviewsData = body['payload']['data'] ?? [];
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
