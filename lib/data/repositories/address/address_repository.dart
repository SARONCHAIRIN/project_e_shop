import 'package:e_shop/data/datasources/adress/adress_service.dart';
import 'package:e_shop/data/models/address/address_model.dart';

class AddressRepository {

  final AddressService service;


  AddressRepository(
      this.service,
      );


  //add or post address for user
  Future<AddressModel> addAddress({
    required int userId,
    required String token,
    required AddressModel address,
  }) async {
    try {
      final result = await service.createAddress(
        userId,
        token,
        address.toJson(),
      );
      return result; //  return inside try
    } catch (e) {
      throw Exception('Failed to add address: $e'); // throw inside catch
    }
  }

  //get address userId
Future<List<AddressModel>> fecthAddressbyUserId({
    required int userId,
    required String token,
    }) async{
    return  service.getAddressbyuserId(userId, token);
    }

    //delete address
    Future<void> deleteAddress({
     required int id,
     required int userId,
     required String token,
    })async{
    await service.deleteAddress(
        id,
        userId,
        token ,
    );
    }

    // Get user's default/first address
    Future<AddressModel?> getAddressById({
      required int userId,
      required String token,
    }) async {
      try {
        return await service.getAddressById(userId, token);
      } catch (e) {
        throw Exception('Failed to fetch address: $e');
      }
    }

    // Update existing address
    Future<void> updateAddress({
      required int userId,
      required String token,
      required int addressId,
      required AddressModel address,
    }) async {
      try {
        await service.updateAddress(
          addressId,
          userId,
          token,
          address.toJson(),
        );
      } catch (e) {
        throw Exception('Failed to update address: $e');
      }
    }
}

