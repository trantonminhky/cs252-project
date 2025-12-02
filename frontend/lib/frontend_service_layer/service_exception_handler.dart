import "package:dio/dio.dart";

class ServiceExceptionHandler {
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
