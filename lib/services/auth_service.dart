import 'dart:convert';
import 'package:dio/dio.dart';
import '../base_url/api_config.dart';
import '../model/login_model.dart';
import '../model/sendmail_model.dart';

class AuthService {
  final Dio _dio = Dio();

  AuthService() {
    _dio.options.followRedirects = true;
    _dio.options.maxRedirects = 3;
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('API Log: $obj'),
    ));
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.data}');

      if (response.statusCode == 200) {
        // Check if response contains error message
        if (response.data.containsKey('Messages ') || response.data.containsKey('Messages')) {
          final errorMessage = response.data['Messages '] ?? response.data['Messages'] ?? 'Login failed';
          throw Exception(errorMessage.toString().trim());
        }
        
        // Check if response contains success data
        if (response.data.containsKey('access_token') && response.data.containsKey('data')) {
          return LoginResponse.fromJson(response.data);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      print('Login DioException: ${e.message}');
      print('Login Response Data: ${e.response?.data}');
      throw Exception('Login error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Login General Exception: $e');
      throw Exception('Login error: $e');
    }
  }

  Future<SendMailResponse> sendMail(SendMailRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.sendMailEndpoint,
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('SendMail Response Status: ${response.statusCode}');
      print('SendMail Response Body: ${response.data}');

      if (response.statusCode == 200) {
        // Check if response contains success data (has all required fields)
        if (response.data.containsKey('Message') && response.data.containsKey('User_mail') && response.data.containsKey('Username')) {
          return SendMailResponse.fromJson(response.data);
        }
        
        // Check if response contains error message (only has Message field)
        if (response.data.containsKey('Message ') || (response.data.containsKey('Message') && !response.data.containsKey('User_mail'))) {
          final errorMessage = response.data['Message '] ?? response.data['Message'] ?? 'Send mail failed';
          throw Exception(errorMessage.toString().trim());
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception('Send mail failed with status: ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      print('SendMail DioException: ${e.message}');
      print('SendMail Response Data: ${e.response?.data}');
      throw Exception('Send mail error: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('SendMail General Exception: $e');
      throw Exception('Send mail error: $e');
    }
  }
}