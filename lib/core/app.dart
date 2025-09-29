import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/login_bloc/login_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/user_bloc/users_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/video_bloc/video_bloc.dart';
import 'package:hipster_assignment/prasentation/login_screen/login_screen.dart';
import 'package:hipster_assignment/prasentation/home_screen/home_screen.dart';

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (_) => LoginBloc()),
        BlocProvider<UsersBloc>(create: (_) => UsersBloc()),
        BlocProvider<VideoCallBloc>(create: (_) => VideoCallBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: loggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
