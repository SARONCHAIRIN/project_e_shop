import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:flutter/material.dart';

import '../desktop/desktop_checkout.dart';

class WebCheckout extends StatelessWidget {
  final AddressRepository repo;

  final TokenStorage storage;

  final int userId;

  final String token;

  final int addressId;

  const WebCheckout({
    super.key,

    required this.repo,

    required this.storage,

    required this.userId,

    required this.token,

    required this.addressId,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopCheckout(
      repo: repo,

      storage: storage,

      userId: userId,

      token: token,

      addressId: addressId,
    );
  }
}
