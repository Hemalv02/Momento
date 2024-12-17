import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:momento/log_in/bloc/login_bloc.dart';
import 'package:momento/register/bloc/register_bloc.dart';
//import 'package:momento/register/bloc/register_bloc.dart';
import 'package:momento/welcome/bloc/welcome_bloc.dart';

class AppBlocProviders {
  static get allBlocProviders => [
        BlocProvider(
          create: (context) => WelcomeBloc(),
        ),
        BlocProvider(create: (context) => LoginBloc()),
        BlocProvider(create: (context) => RegisterBloc()),
      ];
}
