// Model to hold Bakong initiation/QR details
class BakongPaymentModel {
  final String qrString;
  final String md5;
  final String? qrImageBase64;
  final String? qrUrl;

  BakongPaymentModel({
	required this.qrString,
	required this.md5,
	this.qrImageBase64,
	this.qrUrl,
  });

  factory BakongPaymentModel.fromJson(Map<String, dynamic> json) {
	return BakongPaymentModel(
	  qrString: json['qr_string'] ?? json['qr'] ?? '',
	  md5: json['md5'] ?? '',
	  qrImageBase64: json['qr_image'] as String?,
	  qrUrl: json['qr_url'] as String?,
	);
  }

  Map<String, dynamic> toJson() {
	return {
	  'qr_string': qrString,
	  'md5': md5,
	  'qr_image': qrImageBase64,
	  'qr_url': qrUrl,
	};
  }
}


