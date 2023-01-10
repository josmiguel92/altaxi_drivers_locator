part of 'register_cubit.dart';

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState.loading() = _RegisterLoadingState;

  const factory RegisterState.failed({required AlertModel alert}) =
      _RegisterFailedState;

  const factory RegisterState.success({required UserModel user}) =
      _RegisterSuccessState;
}
