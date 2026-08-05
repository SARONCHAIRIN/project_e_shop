import 'package:e_shop/core/responsive/responsive.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';

import 'package:flutter/material.dart';

import 'mobile/mobile_checkout.dart';
import 'tablet/tablet_checkout.dart';
import 'desktop/desktop_checkout.dart';
import 'web/web_checkout.dart';

class CheckoutPage extends StatelessWidget {
  final AddressRepository repo;

  final TokenStorage storage;

  final int userId;

  final String token;

  final int addressId;

  const CheckoutPage({
    super.key,

    required this.repo,

    required this.storage,

    required this.userId,

    required this.token,

    required this.addressId,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return MobileCheckout(
        repo: repo,

        storage: storage,

        userId: userId,

        token: token,

        addressId: addressId,
      );
    }

    if (Responsive.isTablet(context)) {
      return TabletCheckout(
        repo: repo,

        storage: storage,

        userId: userId,

        token: token,

        addressId: addressId,
      );
    }

    if (Responsive.isDesktop(context)) {
      return DesktopCheckout(
        repo: repo,

        storage: storage,

        userId: userId,

        token: token,

        addressId: addressId,
      );
    }

    return WebCheckout(
      repo: repo,

      storage: storage,

      userId: userId,

      token: token,

      addressId: addressId,
    );
  }
}
