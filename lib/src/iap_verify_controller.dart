import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/iap_api.dart';
import 'iap_class.dart';
import 'iap_type_def.dart';

class IapVerifyController extends ChangeNotifier {
  factory IapVerifyController() {
    return IapVerifyController._makeInstance();
  }

  IapVerifyController._();

  factory IapVerifyController._makeInstance() {
    _instance ??= IapVerifyController._();
    return _instance!;
  }

  static IapVerifyController? _instance;

  static IapVerifyController get instance =>
      IapVerifyController._makeInstance();

  static const String _receiptStoreKey = 'iap_purchase_receipt';
  static const String _skuIdStoreKey = 'iap_sku_id';
  static const String _expireTimeKey = 'iap_expire_time';

  String _purchaseReceipt = '';
  String _purchaseSkuId = '';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  int? _expireTime;

  int? get expireTime => _expireTime;

  set expireTime(int? value) {
    _expireTime = value;
    _prefs.setInt(_expireTimeKey, _expireTime ?? 0);
  }

  bool _isProUser = false;

  bool get isProUser => _isProUser;

  set isProUser(bool value) {
    _isProUser = value;
    iapVerifyCallback?.onProStatusChange?.call(value);
  }

  IapVerifyCallback? iapVerifyCallback;

  Future<void> _initPrefs() async {
    _expireTime = await _prefs.getInt(_expireTimeKey);
    _purchaseReceipt = (await _prefs.getString(_receiptStoreKey)) ?? '';
    _purchaseSkuId = (await _prefs.getString(_skuIdStoreKey)) ?? '';
  }

  Future<void> init() async {
    await _initPrefs();
    if (_purchaseReceipt.isEmpty) {
      return;
    }
    await verifyPurchase(
      receipt: _purchaseReceipt,
      productId: _purchaseSkuId,
    );
  }

  /// 内购服务器验证
  Future<void> verifyPurchase({
    required String receipt,
    required String productId,
  }) async {
    try {
      iapVerifyCallback?.onVerifyStart?.call();
      final int expireTime = _expireTime ?? 0;
      isProUser = expireTime > (DateTime.now().millisecondsSinceEpoch / 1000);
      final Map<String, dynamic> verifyParams = <String, dynamic>{
        'purchase_token': receipt,
        'sku_id': productId,
      };
      verifyParams.addAll(
        iapVerifyCallback?.extraVerifyInfo?.call() ?? <String, dynamic>{},
      );
      final IapVerifyFunction? verifyFunction =
          iapVerifyCallback?.verifyFunction;
      if (verifyFunction != null) {
        isProUser = await verifyFunction(verifyParams);
      } else {
        final Response<Map<String, dynamic>> verifyResult =
            await IapApi().verifySub(verifyParams);
        final Map<String, dynamic>? formatResult = verifyResult.data;
        if (formatResult != null) {
          final dynamic expireTimeStamp =
              formatResult['data']?['purchase']?['expires_timestamp'];

          if (expireTimeStamp is int) {
            _expireTime = expireTimeStamp;
            isProUser = (_expireTime ?? 0) >
                (DateTime.now().millisecondsSinceEpoch / 1000);
            _prefs.setInt(_expireTimeKey, _expireTime ?? 0);
          }
        }
      }
      _prefs.setString(_receiptStoreKey, receipt);
      _prefs.setString(_skuIdStoreKey, productId);
    } catch (e) {
      iapVerifyCallback?.onVerifyError?.call();
    }
    iapVerifyCallback?.onVerifyEnd?.call();
  }
}
