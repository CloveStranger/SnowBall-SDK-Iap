import 'package:dio/dio.dart';

import 'iap_api_config.dart';

class IapApi {
  factory IapApi() {
    return IapApi._makeInstance();
  }

  IapApi._();

  factory IapApi._makeInstance() {
    _instance ??= IapApi._();
    return _instance!;
  }

  static IapApi? _instance;

  IapApi get instance => IapApi._makeInstance();

  late IapApiConfig iapApiConfig;

  void init({required String domain}) {
    iapApiConfig = IapApiConfig(domain: domain);
  }

  Future<Response<Map<String, dynamic>>> verifySub(
    Map<String, dynamic> params,
  ) {
    return iapApiConfig.postFileRequest<Map<String, dynamic>>(
      '/api/v2/payment/verify_subs',
      data: params,
    );
  }
}
