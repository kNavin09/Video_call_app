abstract class UsersState {}
class UsersLoading extends UsersState {}
class UsersLoaded extends UsersState {
  final List<Map<String, dynamic>> users;
  UsersLoaded(this.users);
}
