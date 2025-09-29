import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/user_bloc/users_event.dart';
import 'package:hipster_assignment/prasentation/bloc/user_bloc/users_state.dart';
import 'package:hipster_assignment/data/repository/users_repository.dart';


class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final repo = UsersRepository();
  UsersBloc() : super(UsersLoading()) {
    on<FetchUsers>((_, emit) async {
      emit(UsersLoading());
      final users = await repo.fetchUsers();
      emit(UsersLoaded(users));
    });
  }
}
