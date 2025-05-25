import 'package:dio/dio.dart';
import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/utilities/global_variable.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $globalToken',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

Future<Map<String, dynamic>> dio(
    {required String endPoint,
    String method = 'GET',
    Map<String, dynamic> headers = const {},
    bool version = false,
    String versionNumber = '1.0.0',
    Map<String, dynamic> body = const {}}) async {
  print('Making API request:');
  print('Endpoint: $endPoint');
  print('Method: $method');
  print('Global token: $globalToken');

  headers = {
    if (globalToken.isNotEmpty) "Authorization": "Bearer $globalToken",
    if (version) 'version': versionNumber,
    if (method == 'POST' || method == 'PUT') 'Content-Type': 'application/json',
    ...headers
  };

  print('Headers: $headers');
  if (body.isNotEmpty) {
    print('Body: $body');
  }

  Dio dio = Dio(BaseOptions(
    baseUrl: ApiUrls.baseUrl,
    headers: headers,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
    validateStatus: (status) {
      return status! < 500;
    },
  ));

  try {
    Response response = await dio.request(
      endPoint,
      data: body,
      options: Options(
        method: method,
      ),
    );

    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');

    return {
      'statusCode': response.statusCode,
      'data': response.data,
      'message': response.statusMessage,
    };
  } on DioException catch (e) {
    print('Dio error: ${e.message}');
    print('Response: ${e.response}');
    return {
      'statusCode': e.response?.statusCode ?? 500,
      'data': e.response?.data ?? {},
      'message': e.message ?? 'An error occurred',
    };
  } catch (e) {
    print('Unexpected error: $e');
    return {
      'statusCode': 500,
      'data': {},
      'message': e.toString(),
    };
  }
}
