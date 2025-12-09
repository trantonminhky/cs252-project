import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/global/userinfo.dart";
import "package:virtour_frontend/screens/data_factories/review.dart";
import "package:virtour_frontend/frontend_service_layer/service_helpers.dart";

class ReviewService {
  late final Dio dio;
  final String _baseUrl = UserInfo.tunnelUrl;
  Ref ref;

  ReviewService({required String token, required this.ref}) {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  Future<List<Review>> getReviews(String placeName) async {
    return await ServiceHelpers.retryWithTokenRefresh(
      dio: dio,
      ref: ref,
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
