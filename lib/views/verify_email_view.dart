import 'package:flutter/material.dart';
import 'package:gymnotes/services/auth/auth_service.dart';
import '../constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          const Text("We've sent you an email verification. Please open it to verify your account."),
          const Text("If you haven't received a verification email yet, press the button bellow"),
          TextButton(
            onPressed: () async{
              await AuthService.firebase().sendEmailVerification();
            }, 
            child: const Text('Resend email verification')
          ),
          TextButton(
            onPressed: () async{
              await AuthService.firebase().logOut();
              if(mounted){
                Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
              }
            },
            child: const Text('Restart'),
          )
        ]),
    );
  }
}