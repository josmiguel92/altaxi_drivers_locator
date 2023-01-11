import 'dart:async';

import 'package:data_channel/data_channel.dart';
import 'package:dio/dio.dart';
import 'package:altaxi_drivers_locator/features/app/models/alert_model.dart';
import 'package:altaxi_drivers_locator/features/app/models/auth_model.dart';
import 'package:altaxi_drivers_locator/features/app/models/user_model.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AuthRepository {
  AuthRepository(this._dioClient);

  final Dio _dioClient;

  Future<DC<AlertModel, AuthModel>> login({
    required String username,
    required String password,
  }) async {
    // Normally you should wrap the request with dioExceptionHandler.
    // Where error is catched and the returned error message is parsed to
    // create alert. But for the demo I will create alert without localization.

    final pb = PocketBase('https://base.altaxi.app');
    try {
      final userData =
          await pb.collection('drivers').authWithPassword(username, password);

      if (userData.record?.id != null) {
        print({'👤 Logged in as ', username});

        final user = UserModel(
          id: userData.record?.id ?? '',
          username: userData.record?.getStringValue('username') ?? username,
          email: userData.record?.getStringValue('email') ?? username,
          password: '',
        );
        final auth = AuthModel(
          tokenType: 'Bearer ',
          accessToken: userData.token,
          refreshToken: '',
          user: user,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', userData.token);
        await prefs.setString('auth_userId', userData.record?.id ?? '');
        await prefs.setString('auth_password', password);
        await prefs.setString('auth_username', username);

        Timer(const Duration(seconds: 3), () {});

        return DC.data(auth);
      } else {
        final alert = AlertModel.alert(
          message:
              'ID or PW is wrong. Please enter test for demo to both fields.',
          type: AlertType.destructive,
        );

        return DC.error(alert);
      }
    } on ClientException catch (error) {
      final alert = AlertModel.alert(
        message: 'ID or PW is wrong',
        type: AlertType.destructive,
      );

      return DC.error(alert);
    }
  }

  Future<DC<AlertModel, void>> logout({required AuthModel auth}) async {
    try {
      // TODO: Implement custom logout operation with auth model.

      return DC.data(null);
    } catch (e) {
      return DC.error(AlertModel.quiet());
    }
  }
}
