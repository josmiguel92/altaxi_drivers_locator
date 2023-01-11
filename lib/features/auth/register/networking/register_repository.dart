import 'dart:async';
import 'dart:convert';

import 'package:data_channel/data_channel.dart';
import 'package:altaxi_drivers_locator/features/app/models/alert_model.dart';
import 'package:altaxi_drivers_locator/features/app/models/user_model.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase/src/client_exception.dart';

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
    print({
      'email': email,
      'password': password,
      'passwordConfirm': passwordConfirm,
      'username': username,
      'phone': phone,
    });

    String userId = '';
    try {
      final userData = await pb.collection('drivers').create(
        body: {
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'username': username,
          'phone': phone,
        },
      );
      userId = userData.id;
    } on ClientException catch (error) {
      final errorEntries = error.response['data'];

      String message = '';
      if (errorEntries.containsKey('email') != null) {
        message = 'The email is not valid or already exist';
      }
      if (errorEntries.containsKey('username') != null) {
        message = 'The username is not valid';
      }

      final alert = AlertModel.alert(
        message: message,
        type: AlertType.destructive,
      );

      return DC.error(alert);
    }

    final user = UserModel(
      id: userId,
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
