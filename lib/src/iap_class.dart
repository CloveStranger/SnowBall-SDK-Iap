import 'iap_abstract.dart';

class IapVerifyCallback extends IapVerifyCallbackBase {
  const IapVerifyCallback({
    super.extraVerifyInfo,
    super.onVerifyStart,
    super.onVerifyError,
    super.onVerifyEnd,
    super.onProStatusChange,
  });
}

class IapStreamCallBack extends IapStreamCallbackBase {
  IapStreamCallBack({
    super.onStreamPending,
    super.onStreamError,
    super.onStreamPurchased,
    super.onStreamRestored,
    super.onRestoreStart,
    super.onRestoreError,
    super.onRestoreEnd,
    super.onStreamComplete,
    super.onStreamCanceled,
    super.onDone,
    super.onError,
  });
}
