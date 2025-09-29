import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/login_bloc/login_event.dart';
import 'package:hipster_assignment/prasentation/bloc/login_bloc/login_state.dart';
import 'package:hipster_assignment/data/auth_service.dart';
import 'package:flutter/material.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final  emailController = TextEditingController();
  final  passwordController = TextEditingController();

  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return "Email cannot be empty";
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return "Invalid email format";
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return "Password cannot be empty";
    if (value.length < 6) return "Min 6 characters required";
    return null;
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(
      LoginValidationError(
        emailError: _validateEmail(event.email),
        passwordError: state is LoginValidationError
            ? (state as LoginValidationError).passwordError
            : null,
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      LoginValidationError(
        emailError: state is LoginValidationError
            ? (state as LoginValidationError).emailError
            : null,
        passwordError: _validatePassword(event.password),
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final emailError = _validateEmail(event.email);
    final passwordError = _validatePassword(event.password);

    if (emailError != null || passwordError != null) {
      emit(
        LoginValidationError(
          emailError: emailError,
          passwordError: passwordError,
        ),
      );
      return;
    }

    emit(LoginLoading());
    final success = await AuthService.login(event.email, event.password);

    if (success) {
      // Clear controllers after successful login
      emailController.clear();
      passwordController.clear();

      emit(LoginSuccess());
    } else {
      emit(LoginFailure());
    }
  }
}
