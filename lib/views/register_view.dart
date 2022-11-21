import 'package:flutter/material.dart';
import 'package:gymnotes/constants/routes.dart';
import 'package:gymnotes/services/auth/auth_exceptions.dart';
import 'package:gymnotes/services/auth/auth_service.dart';
import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState(){
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'),backgroundColor: const Color.fromRGBO(252, 163, 17, 1.0),),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try{
                await AuthService.firebase().createUser(
                  email: email,
                  password: password
                );
                AuthService.firebase().sendEmailVerification();
                if(mounted){
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }
              } on WeakPasswordAuthException{
                await showErrorDialog(context, 'Weak password');
              } on EmailAlreadyInUseAuthException{
                await showErrorDialog(context, 'This email is already in use');
              } on InvalidEmailAuthException{
                await showErrorDialog(context, 'Email is invalid');
              } on GenericAuthException{
                await showErrorDialog(context, 'Failed to register');
              }
            },
            child: const Text('Register')
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text('Already registered? Login here!')
          )
        ],
      ),
    );
  }
}