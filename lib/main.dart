import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/home_screen.dart';
import 'package:momento/log_in/login.dart';
import 'package:momento/screen/auth.dart';
import 'package:momento/view/themedata.dart';
import 'package:momento/view/dark_themedata.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:momento/welcome/bloc/welcome_bloc.dart';
import 'package:momento/welcome/welcome.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  String supabaseURl=dotenv.env['SUPABASE_URL']??'';
  String supabaseAnonKey=dotenv.env['SUPABASE_ANON_KEY']??'';
  Supabase.initialize(
    url: supabaseURl,
    anonKey: supabaseAnonKey,
    //debug: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WelcomeBloc(),
        ),
        //BlocProvider(create: (context) => LoginBloc()),
      ],
      child: ScreenUtilInit(
        builder: (context, child) => MaterialApp(
          title: 'Momento',
          theme: themeData,
          darkTheme: darkThemeData,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          routes: {
            'login': (context) => const Login(),
          },
          home: const Welcome(), 
          // StreamBuilder(
          //   stream: FirebaseAuth.instance.authStateChanges(),
          //   builder: (ctx, userSnapshot) {
          //     if (userSnapshot.connectionState == ConnectionState.waiting) {
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     }
          //     if (userSnapshot.hasData) {
          //       return HomeScreen();
          //     }
          //     return AuthScreen();
          //   },
          // ),
        ),
      ),
    );
  }
}
