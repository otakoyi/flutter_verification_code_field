<p align="center"><img src="https://github.com/otakoyi/flutter_verification_code_field/blob/readmy_update/display/example.gif"/></p>

<h1 align="center">Flutter Verification Code Field</h1>

<p align="center">A flutter package which contains a verification code field with a number of advantages, namely with the ability to customize your own validation pattern, customize the number of OTP fields or their size, as well as the spacing between OTP fields, also supports text insertion or character replacement in any cell.</p><br>

<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter"
      alt="Platform" />
  </a>
</p><br>

# Table of contents

- [Installing](#installing)
- [Usage](#usage)
- [Bugs or Requests](#bugs-or-requests)


# Installing

### 1. Depend on it

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_verification_code_field: ^1.0.0
```

### 2. Install it

You can install packages from the command line:

with `pub`:

```
$ pub get
```

with `Flutter`:

```
$ flutter pub get
```

### 3. Import it

Now in your `Dart` code, you can use:

```dart
import 'package:flutter_verification_code_field/flutter_verification_code_field.dart';
```

# Usage

`VerificationCodeField` is a _Hook Widget_ that can be used for OTP verification.
Include it in your code like:

```dart
    VerificationCodeField(
      length: 5,
      onFilled: (value) => print(value),
      size: Size(30, 60),
      spaceBetween: 16,
      matchingPattern: RegExp(r'^\d+$'),
    );
```

It has many configurable properties, including:

- `length` – Number of the OTP Fields
- `size` – Size of the single OTP Field
- `spaceBetween` – Space between the OTP fields
- `matchingPattern` – Pattern for validation

There are also custom callback:

- `onFilled` – Callback function that is called when the verification code is filled

# Bugs or Requests

If you encounter any problems feel free to open an [issue](https://github.com/otakoyi/flutter_verification_code_field/issues/new?template=bug_report.md). If you feel the library is missing a feature, please raise a [ticket](https://github.com/otakoyi/flutter_verification_code_field/issues/new?template=feature_request.md) on GitHub and I'll look into it. Pull request are also welcome.