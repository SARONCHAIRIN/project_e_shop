import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';

class BakongPaymentModel {
	final String qrString;
	final String md5;
	final String? qrImageBase64;
	final String? qrUrl;
	final String? orderNumber;
	final int? orderId;
	final double? amount;
	final String? paymentUrl;

	BakongPaymentModel({
		required this.qrString,
		required this.md5,
		this.qrImageBase64,
		this.qrUrl,
		this.orderNumber,
		this.orderId,
		this.amount,
		this.paymentUrl,
	});

	static String _computeMd5(String input) {
		return crypto.md5.convert(utf8.encode(input)).toString();
	}

	factory BakongPaymentModel.fromJson(Map<String, dynamic> json) {
		final qrString = json['qrCode'] ?? json['qr_string'] ?? json['qr'] ?? '';
		final computedMd5 = qrString.isNotEmpty ? _computeMd5(qrString) : '';

		debugPrint('[BakongPaymentModel] qrString length: ${qrString.length}');
		debugPrint('[BakongPaymentModel] computedMd5: $computedMd5');

		return BakongPaymentModel(
			qrString: qrString,
			md5: json['md5'] ?? computedMd5,
			qrImageBase64: json['qr_image'] as String?,
			qrUrl: json['qr_url'] as String?,
			orderNumber: json['orderNumber'] as String?,
			orderId: json['orderId'] as int?,
			amount: (json['amount'] as num?)?.toDouble(),
			paymentUrl: json['paymentUrl'] as String?,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'qr_string': qrString,
			'md5': md5,
			'qr_image': qrImageBase64,
			'qr_url': qrUrl,
			'orderNumber': orderNumber,
			'orderId': orderId,
			'amount': amount,
			'paymentUrl': paymentUrl,
		};
	}
}