import "package:dio/dio.dart";
import "package:virtour_frontend/global/userinfo.dart";

class ServiceHelpers {
  static void addAuthInterceptor(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = UserInfo().accessToken;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static Exception handleDioError(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = e.response?.data?['message'] ??
            'Connection timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        errorMessage = data?['message'] ??
            data?['error']?['message'] ??
            'Server error occurred';
        break;
      case DioExceptionType.cancel:
        errorMessage = e.response?.data?['message'] ?? 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = e.response?.data?['message'] ??
            'Connection failed. Please check your internet.';
        break;
      default:
        errorMessage = e.response?.data?['message'] ??
            'Network error. Please check your connection.';
    }

    return Exception(errorMessage);
  }

  static Future<String> refreshToken(Dio dio) async {
    try {
      final response =
          await dio.post('${UserInfo().tunnelUrl}/api/profile/refresh');
      final body = response.data as Map<String, dynamic>;
      if (response.statusCode == 200) {
        final newToken = body['payload'] as String;
        UserInfo().accessToken = newToken;
        return newToken;
      } else {
        throw Exception(
            'Failed to refresh token. Error ${response.statusCode}: ${body['message']}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // Retry wrapper for API calls with 401 unauthorized handling; will try 3 times before stopping
  static Future<T> retryWithTokenRefresh<T>({
    required Dio dio,
    required Future<T> Function() operation,
  }) async {
    int retryCount = 0;

    while (true) {
      try {
        return await operation();
      } on DioException catch (e) {
        final is401 = e.response?.statusCode == 401;

        if (retryCount < 3) {
          retryCount++;
          try {
            // Refresh token and retry
            await refreshToken(dio);
            continue;
          } catch (refreshError) {
            // If token refresh fails, throw the original error
            throw handleDioError(e);
          }
        }
      }
    }
  }
}
