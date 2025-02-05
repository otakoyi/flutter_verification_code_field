import 'package:flutter/material.dart';
import 'package:flutter_verification_code_field/flutter_verification_code_field.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Flutter Verification Code Field Example')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: MyCodeInput(),
        ),
      ),
    );
  }
}

class MyCodeInput extends StatelessWidget {
  const MyCodeInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VerificationCodeField(
            length: 5,
            spaceBetween: 10,
            onFilled: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$value Submitted successfully! 🎉'),
                ),
              );
            }),
      ],
    );
  }
}
