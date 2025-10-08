import 'dart:convert';
import 'package:dio/dio.dart';
import '../base_url/api_config.dart';
import '../model/login_model.dart';
import '../model/sendmail_model.dart';
import '../model/doctor_profile_model.dart';
import '../model/doctor_update_model.dart';
import '../model/patients_model.dart';
import '../model/request_model.dart';
import '../model/request_response_model.dart';
import '../model/notification_model.dart';
import '../model/result_model.dart';

class AuthService {
  final Dio _dio = Dio();

  AuthService() {
    _dio.options.followRedirects = true;
    _dio.options.maxRedirects = 3;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    _dio.options.sendTimeout = Duration(seconds: 30);
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('API Log: $obj'),
    ));
  }

  // Test network connectivity
  Future<bool> testConnection() async {
    try {
      print('Testing connection to: ${ApiConfig.baseUrl}');
      final response = await _dio.get(
        ApiConfig.baseUrl,
        options: Options(
          headers: {'Accept': 'application/json'},
          sendTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
        ),
      );
      print('Connection test successful: ${response.statusCode}');
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Debug method to test all endpoints
  Future<void> debugEndpoints() async {
    print('=== API ENDPOINTS DEBUG ===');
    print('Base URL: ${ApiConfig.baseUrl}');
    print('Login Endpoint: ${ApiConfig.loginEndpoint}');
    print('SendMail Endpoint: ${ApiConfig.sendMailEndpoint}');
    
    // Test each endpoint
    final endpoints = [
      ApiConfig.loginEndpoint,
      ApiConfig.sendMailEndpoint,
    ];
    
    for (String endpoint in endpoints) {
      try {
        print('Testing endpoint: $endpoint');
        final response = await _dio.get(
          endpoint,
          options: Options(
            sendTimeout: Duration(seconds: 5),
            receiveTimeout: Duration(seconds: 5),
          ),
        );
        print('Endpoint $endpoint - Status: ${response.statusCode}');
      } catch (e) {
        print('Endpoint $endpoint - Error: $e');
      }
    }
    print('=== END DEBUG ===');
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      print('Login Request: ${request.toJson()}');
      print('Login Endpoint: ${ApiConfig.loginEndpoint}');
      
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.data}');
      print('Login Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Handle different error message formats
        final errorKeys = ['Messages ', 'Messages', 'Message ', 'Message', 'error', 'Error'];
        for (String key in errorKeys) {
          if (data.containsKey(key)) {
            final errorMessage = data[key];
            if (errorMessage != null && errorMessage.toString().isNotEmpty) {
              throw Exception(errorMessage.toString().trim());
            }
          }
        }
        
        // Check if response contains success data
        if (data.containsKey('access_token') && data.containsKey('data')) {
          return LoginResponse.fromJson(data);
        } else {
          throw Exception('Invalid response format: Missing access_token or data');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Login DioException Type: ${e.type}');
      print('Login DioException Message: ${e.message}');
      print('Login Response Status: ${e.response?.statusCode}');
      print('Login Response Data: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server response timeout. Please try again.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials. Please check your username and password.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Login service not found. Please contact support.');
      } else {
        final errorMsg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
        throw Exception('Login error: $errorMsg');
      }
    } catch (e) {
      print('Login General Exception: $e');
      throw Exception('Login error: $e');
    }
  }

  Future<SendMailResponse> sendMail(SendMailRequest request) async {
    try {
      print('SendMail Request: ${request.toJson()}');
      print('SendMail Endpoint: ${ApiConfig.sendMailEndpoint}');
      
      final response = await _dio.post(
        ApiConfig.sendMailEndpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('SendMail Response Status: ${response.statusCode}');
      print('SendMail Response Body: ${response.data}');
      print('SendMail Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Check if response contains success data (has all required fields)
        if (data.containsKey('Message') && data.containsKey('User_mail') && data.containsKey('Username')) {
          return SendMailResponse.fromJson(data);
        }
        
        // Handle different error message formats
        final errorKeys = ['Message ', 'Message', 'error', 'Error', 'Messages', 'Messages '];
        for (String key in errorKeys) {
          if (data.containsKey(key)) {
            final errorMessage = data[key];
            if (errorMessage != null && errorMessage.toString().isNotEmpty) {
              // Only throw error if it doesn't contain success fields
              if (!data.containsKey('User_mail') || !data.containsKey('Username')) {
                throw Exception(errorMessage.toString().trim());
              }
            }
          }
        }
        
        throw Exception('Invalid response format: Missing required fields');
      } else {
        throw Exception('Send mail failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('SendMail DioException Type: ${e.type}');
      print('SendMail DioException Message: ${e.message}');
      print('SendMail Response Status: ${e.response?.statusCode}');
      print('SendMail Response Data: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server response timeout. Please try again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Federation ID not found. Please check your ID.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid federation ID format.');
      } else {
        final errorMsg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
        throw Exception('Send mail error: $errorMsg');
      }
    } catch (e) {
      print('SendMail General Exception: $e');
      throw Exception('Send mail error: $e');
    }
  }

  Future<DoctorProfile> getDoctorProfile(int doctorId, String accessToken) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.doctorProfileEndpoint}/$doctorId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('DoctorProfile Response Status: ${response.statusCode}');
      print('DoctorProfile Response Body: ${response.data}');

      if (response.statusCode == 200) {
        // Check if response contains error message
        if (response.data.containsKey('Message')) {
          throw Exception(response.data['Message']);
        }
        
        return DoctorProfile.fromJson(response.data);
      } else {
        throw Exception('Get doctor profile failed with status: ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      print('DoctorProfile DioException: ${e.message}');
      print('DoctorProfile Response Data: ${e.response?.data}');
      throw Exception('Doctor profile error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('DoctorProfile General Exception: $e');
      throw Exception('Doctor profile error: $e');
    }
  }

  Future<void> updateDoctorProfile(int doctorId, DoctorUpdateRequest request, String accessToken) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.doctorUpdateEndpoint}/$doctorId',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('DoctorUpdate Response Status: ${response.statusCode}');
      print('DoctorUpdate Response Body: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Update doctor profile failed with status: ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      print('DoctorUpdate DioException: ${e.message}');
      print('DoctorUpdate Response Data: ${e.response?.data}');
      throw Exception('Doctor update error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('DoctorUpdate General Exception: $e');
      throw Exception('Doctor update error: $e');
    }
  }

  Future<PatientsResponse> getDoctorPatients(int doctorId, String accessToken) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.doctorPatientsEndpoint}/$doctorId/exams-patients',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('DoctorPatients Response Status: ${response.statusCode}');
      print('DoctorPatients Response Body: ${response.data}');

      if (response.statusCode == 200) {
        return PatientsResponse.fromJson(response.data);
      } else {
        throw Exception('Get doctor patients failed with status: ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      print('DoctorPatients DioException: ${e.message}');
      print('DoctorPatients Response Data: ${e.response?.data}');
      throw Exception('Doctor patients error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('DoctorPatients General Exception: $e');
      throw Exception('Doctor patients error: $e');
    }
  }

  Future<void> submitRequest(RequestModel request) async {
    try {
      final response = await _dio.post(
        ApiConfig.requestEndpoint,
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('Request Response Status: ${response.statusCode}');
      print('Request Response Body: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Submit request failed with status: ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      print('Request DioException: ${e.message}');
      print('Request Response Data: ${e.response?.data}');
      throw Exception('Request error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Request General Exception: $e');
      throw Exception('Request error: $e');
    }
  }

  Future<List<RequestResponse>> getRequests(int doctorId, String accessToken) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.getRequestsEndpoint}/$doctorId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('Get Requests Response Status: ${response.statusCode}');
      print('Get Requests Response Body: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check if response contains a message (no requests found)
        if (data is Map<String, dynamic> && data.containsKey('Message')) {
          print('No requests found: ${data['Message']}');
          return [];
        }
        
        // If it's a list, process normally
        if (data is List<dynamic>) {
          return data.map((item) => RequestResponse.fromJson(item)).toList();
        }
        
        // If it's neither, return empty list
        return [];
      } else {
        throw Exception('Get requests failed with status: ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      print('Get Requests DioException: ${e.message}');
      print('Get Requests Response Data: ${e.response?.data}');
      throw Exception('Get requests error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Get Requests General Exception: $e');
      throw Exception('Get requests error: $e');
    }
  }

  Future<List<NotificationModel>> getNotifications(int userId, String accessToken) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.notificationsEndpoint}/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('Notifications Response Status: ${response.statusCode}');
      print('Notifications Response Body: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check if response contains a message (no notifications found)
        if (data is Map<String, dynamic> && data.containsKey('Message')) {
          print('No notifications found: ${data['Message']}');
          return [];
        }
        
        // If it's a list, process normally
        if (data is List<dynamic>) {
          return data.map((item) => NotificationModel.fromJson(item)).toList();
        }
        
        // If it's neither, return empty list
        return [];
      } else {
        throw Exception('Get notifications failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Notifications DioException: ${e.message}');
      print('Notifications Response Data: ${e.response?.data}');
      throw Exception('Notifications error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Notifications General Exception: $e');
      throw Exception('Notifications error: $e');
    }
  }

  Future<ResultDetail> getResultDetail(String type, String code, String matricule, String accessToken) async {
    try {
      final endpoint = '${ApiConfig.resultDetailEndpoint}/$type/$code/$matricule';
      print('ResultDetail Request URL: $endpoint');
      
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('ResultDetail Response Status: ${response.statusCode}');
      print('ResultDetail Response Body: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is List && data.isNotEmpty) {
          return ResultDetail.fromJson(data[0]);
        }
        
        throw Exception('No result detail found');
      } else {
        throw Exception('Get result detail failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('ResultDetail DioException Type: ${e.type}');
      print('ResultDetail DioException Message: ${e.message}');
      print('ResultDetail Response Status: ${e.response?.statusCode}');
      print('ResultDetail Response Data: ${e.response?.data}');
      
      throw Exception('Result detail error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('ResultDetail General Exception: $e');
      throw Exception('Result detail error: $e');
    }
  }

  Future<List<ExamResult>> getResults(int doctorId, String accessToken) async {
    try {
      final endpoint = '${ApiConfig.resultsEndpoint}/$doctorId';
      print('Results Request URL: $endpoint');
      print('Results Request DoctorId: $doctorId');
      
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('Results Response Status: ${response.statusCode}');
      print('Results Response Body: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic> && data.containsKey('Message')) {
          print('No results found: ${data['Message']}');
          return [];
        }
        
        if (data is List<dynamic>) {
          return data.map((item) => ExamResult.fromJson(item)).toList();
        }
        
        return [];
      } else {
        throw Exception('Get results failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Results DioException Type: ${e.type}');
      print('Results DioException Message: ${e.message}');
      print('Results Response Status: ${e.response?.statusCode}');
      print('Results Response Data: ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        return [];
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access to results');
      } else {
        final errorMsg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
        throw Exception('Results error: $errorMsg');
      }
    } catch (e) {
      print('Results General Exception: $e');
      throw Exception('Results error: $e');
    }
  }

  Future<NotificationType> getNotificationType(int typeId, String accessToken) async {
    try {
      final endpoint = '${ApiConfig.notificationTypesEndpoint}$typeId';
      print('NotificationType Request URL: $endpoint');
      print('NotificationType Request TypeId: $typeId');
      print('NotificationType Request Headers: Authorization: Bearer ${accessToken.substring(0, 10)}...');
      
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('NotificationType Response Status: ${response.statusCode}');
      print('NotificationType Response Body: ${response.data}');
      print('NotificationType Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        return NotificationType.fromJson(response.data);
      } else {
        throw Exception('Get notification type failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('NotificationType DioException Type: ${e.type}');
      print('NotificationType DioException Message: ${e.message}');
      print('NotificationType Response Status: ${e.response?.statusCode}');
      print('NotificationType Response Data: ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Notification type $typeId not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access to notification types');
      } else {
        final errorMsg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
        throw Exception('Notification type error: $errorMsg');
      }
    } catch (e) {
      print('NotificationType General Exception: $e');
      throw Exception('Notification type error: $e');
    }
  }
}