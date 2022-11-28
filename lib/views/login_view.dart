import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymnotes/constants/routes.dart';
import 'package:gymnotes/services/auth/auth_exceptions.dart';
import 'package:gymnotes/services/auth/bloc/auth_bloc.dart';
import 'package:gymnotes/services/auth/bloc/auth_event.dart';
import 'package:gymnotes/services/auth/bloc/auth_state.dart';
import 'package:gymnotes/utilities/dialogs/loading_dialog.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

  @override
  void initState() {
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async{
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialogHandle;
          if (!state.isLoading && closeDialog !=null){
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog == null){
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: 'Loading...'
            );
          }

          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, 'User not found');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          backgroundColor: const Color.fromRGBO(252, 163, 17, 1.0),
        ),
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
                  context
                      .read<AuthBloc>()
                      .add(AuthEventLogin(email, password));
                },
                child: const Text('Login')),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    const AuthEventShouldRegister()
                  );
                },
                child: const Text('Not registered yet? Register here!'))
          ],
        ),
      ),
    );
  }
}
