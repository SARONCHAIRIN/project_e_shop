// Future<int> getSkuStock(int skuId) async {
//   final response = await api.post(
//     "/api/v1/inventory/sku/",
//     body: {
//       "skuId": skuId,
//     },
//   );
//
//   final data = response["data"];
//
//   return data["availableQuantity"] ?? 0;
// }