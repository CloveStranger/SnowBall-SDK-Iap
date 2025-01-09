import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'iap_class.dart';
import 'iap_enum.dart';

class IapStoreController {
  factory IapStoreController() {
    return IapStoreController._makeInstance();
  }

  IapStoreController._();

  factory IapStoreController._makeInstance() {
    _instance ??= IapStoreController._();
    return _instance!;
  }

  static IapStoreController? _instance;

  static IapStoreController get instance => IapStoreController._makeInstance();

  final ValueNotifier<bool> _iapAvailable = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _purchaseLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _productsLoading = ValueNotifier<bool>(false);

  ValueNotifier<bool> get iapAvailableNotifier => _iapAvailable;

  ValueNotifier<bool> get purchaseLoadingNotifier => _purchaseLoading;

  ValueNotifier<bool> get productsLoadingNotifier => _productsLoading;

  bool get iapAvailable => _iapAvailable.value;

  set iapAvailable(bool value) {
    _iapAvailable.value = value;
  }

  bool get purchaseLoading => _purchaseLoading.value;

  set purchaseLoading(bool value) {
    _purchaseLoading.value = value;
  }

  bool get productsLoading => _productsLoading.value;

  set productsLoading(bool value) {
    _productsLoading.value = value;
  }

  InAppPurchase? _inAppPurchase = InAppPurchase.instance;

  Set<String> _skuListStore = <String>{};

  final Map<String, List<ProductDetails>> _skuProjectMap =
      <String, List<ProductDetails>>{};

  List<ProductDetails> storeProducts = <ProductDetails>[];

  StreamSubscription<List<PurchaseDetails>>? _subListener;

  IapStreamCallBack? iapStreamCallBack;

  Future<void> init() async {
    try {
      await checkIapAvailable();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> checkIapAvailable() async {
    if (iapAvailable) {
      return;
    }
    iapAvailable = await InAppPurchase.instance.isAvailable();
    if (iapAvailable) {
      _setInAppPurchaseListener();
      return;
    }

    ///如果商店不可用内购实例会无限轮询故销毁
    _inAppPurchase = null;
    throw Exception('IAP is not available');
  }

  /// 统一获取内购商品防止offer token冲突
  /// 用Map做映射为后期大批量sku查询做准备
  Future<void> getProducts(
    List<String> skuList, {
    bool forceRefresh = false,
  }) async {
    try {
      productsLoading = true;
      await checkIapAvailable();
      if (forceRefresh) {
        storeProducts.clear();
      }
      if (storeProducts.length >= skuList.length) {
        return;
      }
      _skuListStore = skuList.toSet();

      final ProductDetailsResponse productDetailsResponse =
          await _inAppPurchase!.queryProductDetails(_skuListStore);

      storeProducts = productDetailsResponse.productDetails;

      for (final ProductDetails item in storeProducts) {
        _skuProjectMap[item.id] = <ProductDetails>[
          item,
          ..._skuProjectMap[item.id] ?? <ProductDetails>[]
        ];
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      productsLoading = false;
    }
  }

  void setIapStreamCallBack(IapStreamCallBack? callBack) {
    iapStreamCallBack = callBack;
  }

  /// 设置内购监听
  Future<void> _setInAppPurchaseListener() async {
    _subListener = _inAppPurchase!.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        debugPrint('purchase on done');
        iapStreamCallBack?.onDone?.call();
        _subListener?.cancel();
        _subListener = null;
        purchaseLoading = false;
      },
      onError: (dynamic error) {
        debugPrint(error.toString());
        debugPrint('purchase error');
        iapStreamCallBack?.onError?.call();
        purchaseLoading = false;
      },
    );
  }

  Future<void> _purchaseStreamCall(PurchaseDetails purchaseDetail) async {
    if (purchaseDetail.status == PurchaseStatus.pending) {
      debugPrint('PurchaseStatus pending');
      iapStreamCallBack?.onStreamPending?.call(purchaseDetail);
      purchaseLoading = true;
    } else {
      if (purchaseDetail.status == PurchaseStatus.error) {
        debugPrint('PurchaseStatus error');
        iapStreamCallBack?.onStreamError?.call(purchaseDetail);
        purchaseLoading = false;
      } else if (purchaseDetail.status == PurchaseStatus.canceled) {
        debugPrint('PurchaseStatus canceled');
        iapStreamCallBack?.onStreamCanceled?.call(purchaseDetail);
        purchaseLoading = false;
      } else if (purchaseDetail.status == PurchaseStatus.purchased) {
        debugPrint('PurchaseStatus purchased');
        final String receipt =
            purchaseDetail.verificationData.serverVerificationData;
        await iapStreamCallBack?.onStreamPurchased?.call(
          purchaseDetail,
          receipt,
          purchaseDetail.productID,
        );
        purchaseLoading = false;
      } else if (purchaseDetail.status == PurchaseStatus.restored) {
        debugPrint('PurchaseStatus restored');
        final String receipt =
            purchaseDetail.verificationData.serverVerificationData;
        await iapStreamCallBack?.onStreamRestored?.call(
          purchaseDetail,
          receipt,
          purchaseDetail.productID,
        );
        purchaseLoading = false;
      }
      if (purchaseDetail.pendingCompletePurchase) {
        debugPrint('PurchaseStatus complete');
        await _inAppPurchase!.completePurchase(purchaseDetail);
        iapStreamCallBack?.onStreamComplete?.call(purchaseDetail);
        purchaseLoading = false;
      }
    }
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    purchaseDetailsList.forEach(_purchaseStreamCall);
  }

  /// 发起购买
  Future<void> startPurchase(
    ProductDetails productDetails,
    IapProductType iapProductType,
  ) async {
    try {
      await checkIapAvailable();
      purchaseLoading = true;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
      if (iapProductType == IapProductType.nonConsumable) {
        await _inAppPurchase!.buyNonConsumable(purchaseParam: purchaseParam);
      } else if (iapProductType == IapProductType.consumable) {
        throw Exception('IapProductType.consumable not support');
      } else {
        throw Exception('IapProductType not support');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      purchaseLoading = false;
    }
  }

  /// 恢复购买
  Future<void> restorePurchase() async {
    try {
      await checkIapAvailable();
      purchaseLoading = true;
      iapStreamCallBack?.onRestoreStart?.call();
      await _inAppPurchase?.restorePurchases();
    } catch (e) {
      iapStreamCallBack?.onRestoreError?.call();
    } finally {
      iapStreamCallBack?.onRestoreEnd?.call();
      purchaseLoading = false;
    }
  }
}
