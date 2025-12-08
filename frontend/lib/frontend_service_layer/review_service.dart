import "package:dio/dio.dart";
import "package:virtour_frontend/global/userinfo.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:virtour_frontend/frontend_service_layer/service_helpers.dart";

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  late final Dio dio;
  final String _baseUrl = UserInfo().tunnelUrl;

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
    ServiceHelpers.addAuthInterceptor(dio);
  }

  Future<List<Review>> getReviews(String placeName) async {
    return await ServiceHelpers.retryWithTokenRefresh(
      dio: dio,
      operation: () async {
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
      },
    );
  }
}
