import 'package:flutter/material.dart';

import '../../snowball_sdk_iap.dart';

typedef IapVerifyContainerBuilder = Widget Function(
    BuildContext context, bool isPro);

class IapVerifyContainer extends StatelessWidget {
  const IapVerifyContainer({super.key, required this.builder});

  final IapVerifyContainerBuilder builder;

  @override
  Widget build(BuildContext context) {
    final IapVerifyController iapVerifyController = IapVerifyController();
    return ListenableBuilder(
      listenable: iapVerifyController,
      builder: (_, __) {
        return builder(context, iapVerifyController.isProUser);
      },
    );
  }
}
