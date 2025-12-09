import 'package:dio/dio.dart';
import 'package:virtour_frontend/global/userinfo.dart';
import 'package:virtour_frontend/frontend_service_layer/service_helpers.dart';
import 'package:virtour_frontend/screens/data_factories/event.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  late final Dio _dio;
  final String _baseUrl = UserInfo.tunnelUrl;

  EventService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '$_baseUrl/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
          'Cache-Control': 'no-cache',
        },
      ),
    );
  }

  factory EventService() {
    return _instance;
  }

  Future<List<Event>?> fetchEvents() async {
    try {
      final response = await _dio.get(
        '/db/export',
        queryParameters: {
          "name": "EventDB",
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data["success"]) {
          try {
            final eventsData = data["payload"]["data"] as Map;
            List<Event> eventsList = [];

            eventsData.forEach((key, value) {
              // Parse timestamps - handle both int and String types
              DateTime parseTimestamp(dynamic timestamp) {
                if (timestamp == null) return DateTime.now();
                if (timestamp is int) {
                  return DateTime.fromMillisecondsSinceEpoch(timestamp);
                }
                if (timestamp is String) {
                  // Try parsing as int first (milliseconds)
                  final intValue = int.tryParse(timestamp);
                  if (intValue != null) {
                    return DateTime.fromMillisecondsSinceEpoch(intValue);
                  }
                  // Try parsing as ISO 8601 date string
                  try {
                    return DateTime.parse(timestamp);
                  } catch (_) {
                    return DateTime.now();
                  }
                }
                return DateTime.now();
              }

              eventsList.add(Event(
                id: key.toString(), // Convert key to String
                name: value["name"]?.toString() ?? 'Unnamed Event',
                location: value["location"]?.toString() ?? "TBD",
                description: value["description"]?.toString() ?? '',
                startTime: parseTimestamp(value["startTime"]),
                endTime: parseTimestamp(value["endTime"]),
                imageUrl: value["imageLink"]?.toString() ?? '',
                numberOfPeople: (value["participants"] as List?)?.length ?? 0,
              ));
            });

            return eventsList;
          } catch (e) {
            throw Exception("Failed to parse data: $e");
          }
        } else {
          throw Exception("API returned success: false");
        }
      } else {
        throw Exception("Failed to fetch events: HTTP ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      print("Failed to fetch events: $e");
      return null;
    }
  }

  Future<List<Event>?> fetchSubscribedEvents(String userID) async {
    try {
      final response = await _dio.get(
        '/event/get-by-userid',
        queryParameters: {
          "userID": userID,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data["success"]) {
          try {
            final eventsData = data["payload"]["data"] as List;
            List<Event> eventsList = [];

            for (var element in eventsData) {
              final eventMap = element as Map<String, dynamic>;
              eventsList.add(Event(
                id: eventMap["id"]?.toString() ?? '',
                name: eventMap["name"] ?? 'Unnamed Event',
                description: eventMap["description"] ?? '',
                location: eventMap["location"] ?? "TBD",
                startTime: eventMap["startTime"] != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        eventMap["startTime"] as int)
                    : DateTime.now(),
                endTime: eventMap["endTime"] != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        eventMap["endTime"] as int)
                    : DateTime.now(),
                imageUrl: eventMap["imageLink"] ?? '',
                numberOfPeople:
                    (eventMap["participants"] as List?)?.length ?? 0,
              ));
            }

            return eventsList;
          } catch (e) {
            throw Exception("Failed to parse data: $e");
          }
        } else {
          throw Exception("API returned success: false");
        }
      } else {
        throw Exception("Failed to fetch events: HTTP ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      print("Failed to fetch events: $e");
      return null;
    }
  }

  Future<bool> subscribeToEvent(String userID, String eventID) async {
    try {
      final response = await _dio.put(
        "/event/$eventID/participants/$userID",
      );

      if (response.statusCode == 200) {
        return response.data["success"] ?? false;
      } else {
        return false;
      }
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      print("Failed to subscribe to event: $e");
      return false;
    }
  }

  Future<bool> unsubscribeFromEvent(String userID, String eventID) async {
    try {
      final response = await _dio.delete(
        "/event/$eventID/participants/$userID",
      );

      if (response.statusCode == 200) {
        return response.data["success"] ?? false;
      } else {
        return false;
      }
    } on DioException catch (e) {
      throw ServiceHelpers.handleDioError(e);
    } catch (e) {
      print("Failed to subscribe to event: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> createEvent({
    required String name,
    required String location,
    required String description,
    String? imageLink,
    int? startTime,
    int? endTime,
  }) async {
    try {
      final response = await _dio.post(
        '/event/',
        data: {
          "name": name,
          "location": location,
          "description": description,
          "imageLink": imageLink,
          "startTime": startTime,
          "endTime": endTime,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return data['payload']['data'];
        }
      }
      return null;
    } on DioException catch (e) {
      print('Error creating event: ${e.message}');
      return null;
    }
  }
}
