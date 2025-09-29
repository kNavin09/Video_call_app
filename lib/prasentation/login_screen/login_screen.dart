import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/login_bloc/login_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/login_bloc/login_event.dart';
import 'package:hipster_assignment/prasentation/bloc/login_bloc/login_state.dart';
import 'package:hipster_assignment/prasentation/home_screen/home_screen.dart';
import 'package:hipster_assignment/prasentation/widgets/comman_textform.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Login failed'),
                ),
              );
            }
          },
          builder: (context, state) {
            String? emailError;
            String? passwordError;

            if (state is LoginValidationError) {
              emailError = state.emailError;
              passwordError = state.passwordError;
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                CustomTextFormField(
                  controller: bloc.emailController,
                  label: 'Email',
                  errorText: emailError,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: bloc.passwordController,
                  label: 'Password',
                  obscureText: true,
                  errorText: passwordError,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(
                      LoginSubmitted(
                        bloc.emailController.text,
                        bloc.passwordController.text,
                      ),
                    );
                  },
                  child: state is LoginLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
