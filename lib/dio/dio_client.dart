import 'package:dio/dio.dart';
import 'package:mess_management/dio/api_urls.dart';
import 'package:mess_management/utilities/global_variable.dart';

dio(
    {required String endPoint,
    String method = 'GET',
    Map<String, dynamic> headers = const {},
    bool version = false,
    String versionNumber = '1.0.0',
    Map body = const {}}) async {
  headers = {
    "Authorization": "Bearer $globalToken",
    if (version) 'version': versionNumber,
    if (method == 'POST' || method == 'PUT') 'Content-Type': 'application/json',
    ...headers
  };
  Dio dio = Dio(BaseOptions(
    baseUrl: ApiUrls().baseUrl,
    headers: headers,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
    validateStatus: (status) {
      return status! < 500;
    },
  ));
  Response response = await dio.request(endPoint,
      data: body,
      options: Options(
        method: method,
        headers: headers,
      ));
  return {
    'statusCode': response.statusCode,
    'data': response.data,
    'response': response
  };
}
