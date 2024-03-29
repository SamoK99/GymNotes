import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymnotes/constants/routes.dart';
import 'package:gymnotes/helpers/loading/loading_screen.dart';
import 'package:gymnotes/services/auth/bloc/auth_bloc.dart';
import 'package:gymnotes/services/auth/bloc/auth_event.dart';
import 'package:gymnotes/services/auth/bloc/auth_state.dart';
import 'package:gymnotes/services/auth/firebase_auth_provider.dart';
import 'package:gymnotes/views/forgot_password_view.dart';
import 'package:gymnotes/views/login_view.dart';
import 'package:gymnotes/views/notes/create_update_note_view.dart';
import 'package:gymnotes/views/notes/notes_view.dart';
import 'package:gymnotes/views/register_view.dart';
import 'package:gymnotes/views/verify_email_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => 
    runApp(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        title: 'GymNotes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.orange[400],
            secondary: Colors.orange[400]
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color.fromRGBO(85, 88, 95, 1),
            selectionHandleColor: Color.fromRGBO(85, 88, 95, 1)
          )
        ),
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const Homepage(),
        ),
        routes: {
          createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
        },
      ),
    ));
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading){
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn){
          return const NotesView();
        } else if (state is AuthStateNeedsVerification){
          return const VerifyEmailView();
        } else if ( state is AuthStateLoggedOut){
          return const LoginView();
        } else if (state is AuthStateForgotPassword){
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering){
          return const RegisterView();
        } else{
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      }
    );
  }
}
