import "package:dio/dio.dart";
import "package:virtour_frontend/global/userinfo.dart";

class ServiceHelpers {
  static void addAuthInterceptor(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = UserInfo().userSessionToken;
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
}
