import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/login/screen/signup_body.dart';

@Preview(name: 'SignupBody')
Widget signupBodyPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignupBody(
      emailController: TextEditingController(text: 'preview@example.com'),
      passwordController: TextEditingController(text: 'password123'),
      onRegisterPressed: () {},
      onReturnToLoginPressed: () {},
    ),
  );
}
