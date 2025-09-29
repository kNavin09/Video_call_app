import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/user_bloc/users_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/user_bloc/users_event.dart';
import 'package:hipster_assignment/prasentation/bloc/user_bloc/users_state.dart';
import 'package:hipster_assignment/prasentation/video_call_screen/video_call_screen.dart';
import 'package:hipster_assignment/data/auth_service.dart';
import 'package:hipster_assignment/prasentation/login_screen/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<UsersBloc>().add(FetchUsers());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await AuthService.logout();
              // ✅ Navigate back to login screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UsersLoaded) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, i) {
                final user = state.users[i];
                final name = user['first_name'] ?? '';
                final email = user['email'] ?? '';
                final avatar = user['avatar'] ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                    child: avatar.isEmpty
                        ? Text(name.isNotEmpty ? name[0] : "?")
                        : null,
                  ),
                  title: Text(name),
                  subtitle: Text(email),
                  onTap: () {
                    // ✅ Generate a unique channelId (for testing use email or UID)
                    final channelId = "channel_${user['id']}";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoCallScreen(
                          channelId: channelId,
                          isIncoming: false,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const Center(child: Text('Error loading users'));
        },
      ),
    );
  }
}
