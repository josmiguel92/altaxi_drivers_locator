import 'dart:async';

import 'package:data_channel/data_channel.dart';
import 'package:flutter_advanced_boilerplate/features/app/models/alert_model.dart';
import 'package:flutter_advanced_boilerplate/features/app/models/user_model.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

@lazySingleton
class RegisterRepository {
  RegisterRepository();

  Future<DC<AlertModel, UserModel>> register({
    required String username,
    required String password,
    required String phone,
    required String passwordConfirm,
    required String email,
  }) async {
    // Normally you should wrap the request with dioExceptionHandler.
    // Where error is catched and the returned error message is parsed to
    // create alert. But for the demo I will create alert without localization.

    // final isIdPwCorrect = username == 'test' && password == 'test';

    // if (isIdPwCorrect) {
    final pb = PocketBase('https://base.altaxi.app');
    final userData = await pb.collection('drivers').create(
      body: {
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'username': username,
        'phone': phone,
      },
    );

    final user = UserModel(
      id: userData.id,
      username: username,
      password: password,
      email: email,
    );

    Timer(const Duration(seconds: 3), () {});

    return DC.data(user);
    // } else {
    //   final alert = AlertModel.alert(
    //     message:
    //         'ID or PW is wrong. Please enter test for demo to both fields.',
    //     type: AlertType.destructive,
    //   );

    //   return DC.error(alert);
    // }
  }
}
