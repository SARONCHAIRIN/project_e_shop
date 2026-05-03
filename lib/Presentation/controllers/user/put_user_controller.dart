import 'package:e_shop/data/models/user/put_user_model.dart';
import 'package:e_shop/data/repositories/user/put_user_repo.dart';

class PutUserController {
late  final PutUserRepo repo;

  PutUserController(this.repo);

  Future<bool> updateUser(int userId, PutUserModel user) async{
  return await repo.updateUser(userId, user);
  }
}
