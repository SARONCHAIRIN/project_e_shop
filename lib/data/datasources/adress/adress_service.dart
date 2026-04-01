

import 'dart:convert';
import 'package:e_shop/core/constants/address/adress_constants.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/address/address_model.dart';

class AddressService {


  //post address for user
  Future<dynamic> createAddress(int userId, String token, Map<String , dynamic> body )
  async {
    final url = Uri.parse("${AddressConstants.createaddress}/$userId");

    try{
      final response  = await http.post(
        url,
        headers: {
          'accept' : 'application/json',
          'Content-Type' :  'application/json',
          'Authorization' : 'Bearer $token',
        },
        body: jsonEncode(body),

      );
      print('Response Body ${response.body}');
      print('Status API ${response.statusCode}');
      return jsonDecode(response.body);

    }catch(e){
      throw Exception('aoi not fount');
    }
    }

    //get address by userId
  Future<List<AddressModel>> getAddressbyuserId(int userId , String token)
  async{

    final url = Uri.parse("${AddressConstants.getaddressbyuserId}/$userId");

    try{
      final response = await  http.get(
          url,
          headers: {
            'accept' : 'Application/json',
            "Authorization" : 'Bearer $token',
          }
      );
      // final List<dynamic> jsonList = jsonDecode(response.body);
      //
      // // Map each item -> AddressModel.fromJson(item['data'])
      // return jsonList
      //     .map((item) => AddressModel.fromJson(item['data']))
      //     .toList();


      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final decoded = jsonDecode(response.body);

      //  CASE: response is LIST
      if (decoded is List) {
        return decoded.map((item) {
          return AddressModel.fromJson(item['data']);
        }).toList();
      }

      //  CASE: response is OBJECT
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];

        if (data is List) {
          return data.map((e) => AddressModel.fromJson(e)).toList();
        }

        if (data is Map<String, dynamic>) {
          return [AddressModel.fromJson(data)];
        }
      }

      return [];


    }catch(e){
      throw Exception("error $e");
    }
  }


  Future<void> deleteAddress(int id, int userId, String token) async {
    final url = Uri.parse("${AddressConstants.deleteAddress}/$id/user/$userId");

    try {
      final response = await http.delete(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token', // remove extra space
        },
      );

      print('API status: ${response.statusCode}');
      print('API body: ${response.body}');

      // Success: 200 OK or 204 No Content
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Address deleted successfully');
        return; // normal exit
      }

      // Any other status = failure
      throw Exception('Failed to delete address: ${response.statusCode}');

    } catch (e) {
      throw Exception('Error deleting address: $e');
    }
  }
}