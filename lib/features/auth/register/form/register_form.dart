import 'dart:io';

import 'package:reactive_forms/reactive_forms.dart';
import 'package:universal_platform/universal_platform.dart';

FormGroup get registerForm => FormGroup(
      {
        'email': FormControl<String>(
          value: '',
          validators: [
            Validators.required,
            Validators.minLength(4),
            Validators.email,
          ],
        ),
        'username': FormControl<String>(
          value: '',
          validators: [
            Validators.required,
            Validators.minLength(4),
          ],
        ),
        'password': FormControl<String>(
          value: '',
          validators: [
            Validators.required,
            Validators.minLength(8),
          ],
        ),
        'passwordConfirm': FormControl<String>(
          value: '',
          validators: [
            Validators.required,
            Validators.minLength(8),
            Validators.mustMatch('password', 'passwordConfirm'),
          ],
        ),
        if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) ...{
          'photo': FormControl<File>(),
        },
        'phone': FormControl<String>(
          value: '',
          validators: [
            Validators.required,
            Validators.minLength(8),
          ],
        ),
      },
      validators: [
        Validators.mustMatch('password', 'passwordConfirm'),
      ],
    );
