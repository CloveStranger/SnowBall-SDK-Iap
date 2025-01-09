import 'api/iap_api.dart';
import 'iap_store_controller.dart';
import 'iap_verify_controller.dart';

class IapLib {
  factory IapLib() {
    return IapLib._makeInstance();
  }

  IapLib._();

  factory IapLib._makeInstance() {
    _instance ??= IapLib._();
    return _instance!;
  }

  static IapLib? _instance;

  static IapLib get instance => IapLib._makeInstance();

  final IapVerifyController iapVerifyController = IapVerifyController();

  final IapStoreController iapProductInfoStore = IapStoreController();

  void init({required String apiDomain}) {
    IapApi().init(domain: apiDomain);
    iapVerifyController.init();
    iapProductInfoStore.init();
  }
}
