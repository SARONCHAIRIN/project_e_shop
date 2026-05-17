// Payment method enum and helpers
enum PaymentMethod {
  cod,
  bakong,
}

extension PaymentMethodExtension on PaymentMethod {
  String get value {
	switch (this) {
	  case PaymentMethod.cod:
		return 'COD';
	  case PaymentMethod.bakong:
		return 'BAKONG';
	}
  }

  static PaymentMethod fromString(String? s) {
	if (s == null) return PaymentMethod.cod;
	switch (s.toUpperCase()) {
	  case 'BAKONG':
		return PaymentMethod.bakong;
	  case 'COD':
	  default:
		return PaymentMethod.cod;
	}
  }
}


