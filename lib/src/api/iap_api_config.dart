import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef ApiResponse<T> = Response<T>;

class CustomInterceptors extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options); // 使用 handler.next 代替 super.onRequest
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response); // 使用 handler.next 代替 super.onResponse
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    handler.next(err); // 使用 handler.next 代替 super.onError
  }
}

class IapApiConfig {
  IapApiConfig({required this.domain}) {
    _dio.options.baseUrl = domain;
    _dio.options.responseType = ResponseType.json;
    _dio.interceptors.add(CustomInterceptors());
  }

  final String domain;
  final Dio _dio = Dio();

  Future<ApiResponse<T>> getRequest<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.get<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }

  Future<ApiResponse<T>> postRequest<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      options: options,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<ApiResponse<T>> postFileRequest<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: FormData.fromMap(data ?? {}),
      options: options,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
