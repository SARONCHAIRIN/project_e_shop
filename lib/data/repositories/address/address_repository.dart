import 'package:e_shop/data/datasources/adress/adress_service.dart';
import 'package:e_shop/data/datasources/user/get_user_Id_service.dart';
import 'package:e_shop/data/models/address/address_model.dart';
import 'package:http/http.dart';

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
}

