import 'package:in_app_purchase/in_app_purchase.dart';

/// Callback function type for handling purchase details.
typedef IapStreamCallBackFunc = Future<void> Function(
  PurchaseDetails purchaseDetails,
);

/// Callback function type for handling purchase details that need verification.
typedef IapStreamNeedVerifyCallBackFunc = Future<void> Function(
  PurchaseDetails purchaseDetails,
  String receipt,
  String skuId,
);

/// Function type for verifying purchase parameters.
typedef IapVerifyFunction = Future<bool> Function(
  Map<String, dynamic> verifyParams,
);
