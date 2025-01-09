import 'package:flutter/material.dart';

import '../iap_enum.dart';
import '../iap_store_controller.dart';

typedef IapProductRefreshBuilder = Widget Function(
    BuildContext context, bool value);

class IapProductRefreshContainer extends StatelessWidget {
  final Widget child;
  final IapProductRefreshType refreshType;
  final IapProductRefreshBuilder iapProductRefreshBuilder;

  const IapProductRefreshContainer({
    super.key,
    required this.child,
    required this.refreshType,
    required this.iapProductRefreshBuilder,
  });

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool>? getValueNotifier() {
      if (refreshType == IapProductRefreshType.iapAvailable) {
        return IapStoreController().iapAvailableNotifier;
      } else if (refreshType == IapProductRefreshType.purchaseLoading) {
        return IapStoreController().purchaseLoadingNotifier;
      } else if (refreshType == IapProductRefreshType.productsLoading) {
        return IapStoreController().productsLoadingNotifier;
      }
      return null;
    }

    ValueNotifier<bool>? valueNotifier = getValueNotifier();
    if (valueNotifier != null) {
      return ValueListenableBuilder(
        valueListenable: valueNotifier,
        builder: (_, value, __) {
          return iapProductRefreshBuilder(context, value);
        },
      );
    }
    return Container(
      child: child,
    );
  }
}
