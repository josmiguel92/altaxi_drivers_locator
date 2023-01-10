import 'dart:async';

import 'package:flutter_advanced_boilerplate/features/app/models/alert_model.dart';
import 'package:flutter_advanced_boilerplate/features/app/models/user_model.dart';
import 'package:flutter_advanced_boilerplate/features/auth/register/networking/register_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'register_cubit.freezed.dart';
part 'register_state.dart';

@lazySingleton
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._registerRepository)
      : super(const RegisterState.loading());

  final RegisterRepository _registerRepository;

  Future<void> register({
    required String username,
    required String password,
    required String passwordConfirm,
    required String email,
    required String phone,
  }) async {
    emit(const RegisterState.loading());

    final response = await _registerRepository.register(
      username: username,
      password: password,
      passwordConfirm: passwordConfirm,
      phone: phone,
      email: email,
    );

    await Future.delayed(const Duration(seconds: 2), () {});

    response.pick(
      onError: (alert) => emit(RegisterState.failed(alert: alert)),
    );
  }
}
