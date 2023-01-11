import 'dart:io';

import 'package:flutter/material.dart';
import 'package:altaxi_drivers_locator/features/app/models/alert_model.dart';
import 'package:altaxi_drivers_locator/features/app/widgets/customs/custom_button.dart';
import 'package:altaxi_drivers_locator/features/app/widgets/customs/custom_textfield.dart';
import 'package:altaxi_drivers_locator/features/app/widgets/utils/keyboard_dismisser.dart';
import 'package:altaxi_drivers_locator/features/app/widgets/utils/material_splash_tappable.dart';
import 'package:altaxi_drivers_locator/features/auth/register/blocs/register_cubit.dart';
import 'package:altaxi_drivers_locator/features/auth/register/form/register_form.dart';
import 'package:altaxi_drivers_locator/features/auth/register/networking/register_repository.dart';
import 'package:altaxi_drivers_locator/i18n/strings.g.dart';
import 'package:altaxi_drivers_locator/utils/constants.dart';
import 'package:altaxi_drivers_locator/utils/helpers/bar_helper.dart';
import 'package:altaxi_drivers_locator/utils/helpers/permission_helper.dart';
import 'package:altaxi_drivers_locator/utils/methods/shortcuts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:universal_platform/universal_platform.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    @visibleForTesting this.cubit,
    @visibleForTesting this.form,
  });

  final RegisterCubit? cubit;
  final FormGroup? form;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ImagePicker picker = ImagePicker();

  late RoundedLoadingButtonController _btnController;
  late FormGroup _form;

  @override
  void initState() {
    _btnController = RoundedLoadingButtonController();
    _form = widget.form ?? registerForm;
    super.initState();
  }

  File? get photo => _form.control('photo').value as File?;
  String get email => _form.control('email').value.toString();
  String get username => _form.control('username').value.toString();
  String get password => _form.control('password').value.toString();
  String get passwordConfirm =>
      _form.control('passwordConfirm').value.toString();
  String get phone => _form.control('phone').value.toString();

  Future<void> checkPermission() async {
    final hasPermission = await checkPhotosPermission();

    if (hasPermission && mounted) {
      await selectPhoto();
    } else {
      BarHelper.showAlert(
        context,
        alert: AlertModel(
          message: context.t.core.file_picker.no_permission,
          type: AlertType.destructive,
        ),
      );
    }
  }

  Future<void> selectPhoto() async {
    const maxPhotoSizeInByte = 2000000;

    final photo =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 25);

    if (photo == null) {
      return;
    }

    final size = await photo.length();

    if (!mounted) {
      return;
    }

    if (size <= maxPhotoSizeInByte) {
      // Execute the upload operation with bloc for photo. For ex.
      // Create a form data and send a post request with dio in your repo.
      // FormData formData = FormData.fromMap({
      //   "image": await MultipartFile.fromFile(photo.path),
      // });
      _form.control('photo').value = File(photo.path);
    } else {
      BarHelper.showAlert(
        context,
        alert: AlertModel(
          message: context.t.core.file_picker
              .size_warning(maxSize: maxPhotoSizeInByte / 1000000),
          type: AlertType.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (_) => RegisterCubit(RegisterRepository()),
      child: KeyboardDismisserWidget(
        child: ReactiveForm(
          formGroup: _form,
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: $constants.insets.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (UniversalPlatform.isAndroid ||
                      UniversalPlatform.isIOS) ...{
                    ReactiveFormConsumer(
                      builder: (context, formGroup, child) {
                        return MaterialSplashTappable(
                          radius: 50,
                          onTap: checkPermission,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: getCustomOnPrimaryColor(context)
                                .withOpacity(0.05),
                            backgroundImage: photo != null
                                ? Image.file(
                                    photo!,
                                    fit: BoxFit.cover,
                                  ).image
                                : null,
                            child: photo == null
                                ? Icon(
                                    MdiIcons.image,
                                    color: getTheme(context).onBackground,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: $constants.insets.md),
                  },
                  CustomTextField(
                    key: const Key('username'),
                    formControlName: 'username',
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    labelText: context.t.core.form.username.label,
                    hintText: context.t.core.form.username.hint,
                    minLength: 4,
                    isRequired: true,
                  ),
                  CustomTextField(
                    key: const Key('email'),
                    formControlName: 'email',
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    labelText: context.t.core.form.email.label,
                    hintText: context.t.core.form.email.hint,
                    minLength: 4,
                    isRequired: true,
                  ),
                  ReactiveFormConsumer(
                    builder: (context, formGroup, child) {
                      return CustomTextField(
                        key: const Key('password'),
                        formControlName: 'password',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        obscureText: true,
                        labelText: context.t.core.form.password.label,
                        hintText: context.t.core.form.password.hint,
                        minLength: 8,
                        isRequired: true,
                        onSubmitted: _form.valid
                            ? (_) => BlocProvider.of<RegisterCubit>(context)
                                    .register(
                                  username: username,
                                  password: password,
                                  passwordConfirm: passwordConfirm,
                                  email: email,
                                  phone: phone,
                                )
                            : null,
                      );
                    },
                  ),
                  ReactiveFormConsumer(
                    builder: (context, formGroup, child) {
                      return CustomTextField(
                        key: const Key('passwordConfirm'),
                        formControlName: 'passwordConfirm',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        obscureText: true,
                        labelText: context.t.core.form.passwordConfirm.label,
                        hintText: context.t.core.form.passwordConfirm.hint,
                        minLength: 8,
                        isRequired: true,
                        onSubmitted: _form.valid
                            ? (_) => BlocProvider.of<RegisterCubit>(context)
                                    .register(
                                  username: username,
                                  password: password,
                                  passwordConfirm: passwordConfirm,
                                  email: email,
                                  phone: phone,
                                )
                            : null,
                      );
                    },
                  ),
                  CustomTextField(
                    key: const Key('phone'),
                    formControlName: 'phone',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.go,
                    labelText: context.t.core.form.phone.label,
                    hintText: context.t.core.form.phone.hint,
                    minLength: 8,
                    isRequired: true,
                  ),
                  SizedBox(height: $constants.insets.sm),
                  ReactiveFormConsumer(
                    builder: (context, formGroup, child) => CustomButton(
                      controller: _btnController,
                      width: getSize(context).width,
                      text: context.t.register.register_button,
                      onPressed: _form.valid
                          ? () =>
                              BlocProvider.of<RegisterCubit>(context).register(
                                username: username,
                                password: password,
                                passwordConfirm: passwordConfirm,
                                email: email,
                                phone: phone,
                              )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return BlocListener<RegisterCubit, RegisterState>(
      bloc: context.read<RegisterCubit>(),
      listener: (context, state) {
        state.maybeWhen(
          loading: () {
            _form
              ..unfocus()
              ..markAsDisabled();
            _btnController.start();
          },
          failed: (alert) {
            _form.markAsEnabled();
            _btnController.reset();

            BarHelper.showAlert(
              context,
              alert: alert,
              isTest: widget.cubit != null,
            );
          },
          success: (_) {
            _form
              ..reset()
              ..markAsEnabled();
            _btnController.reset();

            if (widget.cubit != null) {
              BarHelper.showAlert(
                context,
                alert: AlertModel.alert(
                  message: context.t.core.test.succeded,
                  type: AlertType.constructive,
                ),
                isTest: true,
              );
            }
          },
          orElse: () {
            _form.markAsEnabled();
            _btnController.reset();
          },
        );
      },
      child: KeyboardDismisserWidget(
        child: ReactiveForm(
          formGroup: _form,
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: $constants.insets.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (UniversalPlatform.isAndroid ||
                      UniversalPlatform.isIOS) ...{
                    ReactiveFormConsumer(
                      builder: (context, formGroup, child) {
                        return MaterialSplashTappable(
                          radius: 50,
                          onTap: checkPermission,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: getCustomOnPrimaryColor(context)
                                .withOpacity(0.05),
                            backgroundImage: photo != null
                                ? Image.file(
                                    photo!,
                                    fit: BoxFit.cover,
                                  ).image
                                : null,
                            child: photo == null
                                ? Icon(
                                    MdiIcons.image,
                                    color: getTheme(context).onBackground,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: $constants.insets.md),
                  },
                  CustomTextField(
                    key: const Key('username'),
                    formControlName: 'username',
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    labelText: context.t.core.form.username.label,
                    hintText: context.t.core.form.username.hint,
                    minLength: 4,
                    isRequired: true,
                  ),
                  CustomTextField(
                    key: const Key('email'),
                    formControlName: 'email',
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    labelText: context.t.core.form.username.label,
                    hintText: context.t.core.form.username.hint,
                    minLength: 4,
                    isRequired: true,
                  ),
                  ReactiveFormConsumer(
                    builder: (context, formGroup, child) {
                      return CustomTextField(
                        key: const Key('password'),
                        formControlName: 'password',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        obscureText: true,
                        labelText: context.t.core.form.password.label,
                        hintText: context.t.core.form.password.hint,
                        minLength: 4,
                        isRequired: true,
                        onSubmitted: _form.valid
                            ? (_) => BlocProvider.of<RegisterCubit>(context)
                                    .register(
                                  username: username,
                                  password: password,
                                  passwordConfirm: passwordConfirm,
                                  email: email,
                                  phone: phone,
                                )
                            : null,
                      );
                    },
                  ),
                  SizedBox(height: $constants.insets.sm),
                  ReactiveFormConsumer(
                    builder: (context, formGroup, child) => CustomButton(
                      controller: _btnController,
                      width: getSize(context).width,
                      text: context.t.login.login_button,
                      onPressed: _form.valid
                          ? () =>
                              BlocProvider.of<RegisterCubit>(context).register(
                                username: username,
                                password: password,
                                passwordConfirm: passwordConfirm,
                                email: email,
                                phone: phone,
                              )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
