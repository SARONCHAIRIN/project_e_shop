

import 'package:e_shop/data/datasources/user/put_user_service.dart';
import 'package:e_shop/data/models/user/put_user_model.dart';

class PutUserRepo {
 late final PutUserService putUserService;

 PutUserRepo(
     this.putUserService,
     );
 Future<bool> updateUser(int userId, PutUserModel user) async {
   return putUserService.updateUser(userId, user);
 }
}