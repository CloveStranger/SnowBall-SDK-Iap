import 'iap_type_def.dart';

/// Purchase Verify Callback
/// 内购验证回调
abstract class IapVerifyCallbackBase {
  const IapVerifyCallbackBase({
    this.verifyFunction,
    this.extraVerifyInfo,
    this.onVerifyStart,
    this.onVerifyError,
    this.onVerifyEnd,
    this.onProStatusChange,
  });

  final Map<String, dynamic> Function()? extraVerifyInfo;
  final void Function()? onVerifyStart;
  final void Function()? onVerifyError;
  final void Function()? onVerifyEnd;
  final void Function(bool)? onProStatusChange;
  final IapVerifyFunction? verifyFunction;
}

/// Purchase Callback
/// 内购监听回调
abstract class IapStreamCallbackBase {
  const IapStreamCallbackBase({
    this.onStreamPending,
    this.onStreamError,
    this.onStreamPurchased,
    this.onStreamRestored,
    this.onRestoreStart,
    this.onRestoreError,
    this.onRestoreEnd,
    this.onStreamComplete,
    this.onStreamCanceled,
    this.onDone,
    this.onError,
  });

  final IapStreamCallBackFunc? onStreamPending;
  final IapStreamCallBackFunc? onStreamError;

  final IapStreamNeedVerifyCallBackFunc? onStreamPurchased;
  final IapStreamNeedVerifyCallBackFunc? onStreamRestored;

  final void Function()? onRestoreStart;
  final void Function()? onRestoreError;
  final void Function()? onRestoreEnd;

  final IapStreamCallBackFunc? onStreamComplete;
  final IapStreamCallBackFunc? onStreamCanceled;

  final void Function()? onDone;
  final void Function()? onError;
}
