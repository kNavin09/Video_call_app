import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:hipster_assignment/prasentation/bloc/video_bloc/video_bloc.dart';
import 'package:hipster_assignment/prasentation/bloc/video_bloc/video_event.dart';
import 'package:hipster_assignment/prasentation/bloc/video_bloc/video_state.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelId;
  final bool isIncoming;

  const VideoCallScreen({
    Key? key,
    required this.channelId,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late VideoCallBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<VideoCallBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askChannelId();
    });
  }

  Future<void> _askChannelId() async {
    final channelController = TextEditingController(text: "room");

    String? channelId = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool permissionDenied = false;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> onJoinPressed() async {
              bool granted = await checkPermissions();
              if (granted) {
                Navigator.of(context).pop(
                  channelController.text.trim().isEmpty
                      ? "defaultChannel"
                      : channelController.text.trim(),
                );
              } else {
                setState(() {
                  permissionDenied = true;
                });
              }
            }

            return AlertDialog(
              title: const Text('Enter Channel ID'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: channelController,
                    decoration: const InputDecoration(hintText: 'Channel ID'),
                  ),
                  if (permissionDenied)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Camera and microphone permissions are required to join a call.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: onJoinPressed,
                  child: const Text('Join'),
                ),
              ],
            );
          },
        );
      },
    );

    if (channelId != null && channelId.isNotEmpty) {
      bloc.add(JoinCall(channelId: channelId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<VideoCallBloc, VideoCallState>(
        listener: (context, state) {
          if (state is VideoCallInitial) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<VideoCallBloc, VideoCallState>(
          builder: (context, state) {
            return Stack(
              children: [
                Positioned.fill(child: _renderRemoteVideo(state, bloc)),
                Positioned(
                  top: 40,
                  right: 16,
                  width: 120,
                  height: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _renderLocalVideo(state, bloc),
                  ),
                ),
                if (state.isJoined)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Mute
                          _circleButton(
                            icon: state.muteAudio ? Icons.mic_off : Icons.mic,
                            bgColor: Colors.blue,
                            onPressed: () => bloc.add(ToggleMute()),
                          ),
                          const SizedBox(width: 12),
                          // End Call
                          _circleButton(
                            icon: Icons.call_end,
                            bgColor: Colors.red,
                            onPressed: () {
                              bloc.add(LeaveCall());
                            },
                          ),
                          const SizedBox(width: 12),
                          // Toggle Video
                          _circleButton(
                            icon: state.disableVideo
                                ? Icons.videocam_off
                                : Icons.videocam,
                            bgColor: Colors.blue,
                            onPressed: () => bloc.add(ToggleVideo()),
                          ),
                          const SizedBox(width: 12),
                          _circleButton(
                            icon: Icons.cameraswitch,
                            bgColor: Colors.purple,
                            onPressed: () {
                              bloc.add(SwitchCamera());
                            },
                          ),
                          const SizedBox(width: 12),

                          // Start/Stop Screen Share
                          _circleButton(
                            icon: state.isScreenSharing
                                ? Icons.stop_screen_share
                                : Icons.screen_share,
                            bgColor: Colors.green,
                            onPressed: () {
                              if (state.isScreenSharing) {
                                bloc.add(StopScreenShare());
                              } else {
                                bloc.add(
                                  StartScreenShare(
                                    screenWidth: screenSize.width.toInt(),
                                    screenHeight: screenSize.height.toInt(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color bgColor,
    required VoidCallback onPressed,
  }) => CircleAvatar(
    radius: 28,
    backgroundColor: bgColor,
    child: IconButton(
      icon: Icon(icon, color: Colors.white, size: 28),
      onPressed: onPressed,
    ),
  );

  Widget _renderLocalVideo(VideoCallState state, VideoCallBloc bloc) {
    if (!state.isJoined) return Container(color: Colors.black38);

    if (state.disableVideo) {
      return Container(
        color: Colors.black38,
        child: const Center(
          child: Text('Camera Off', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: bloc.engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _renderRemoteVideo(VideoCallState state, VideoCallBloc bloc) {
    if (!state.isJoined || state.remoteUid == null) {
      return Container(
        color: Colors.black38,
        child: const Center(
          child: Text(
            "Waiting for remote user...",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final active = state as VideoCallActive;

    // If remote user is sharing screen → render screen share
    if (active.isScreenSharing) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: bloc.engine,
          canvas: const VideoCanvas(uid: 1), // screen share UID
          connection: RtcConnection(channelId: active.channelName!),
        ),
      );
    }

    // Else render remote camera feed
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: bloc.engine,
        canvas: VideoCanvas(uid: active.remoteUid!),
        connection: RtcConnection(channelId: active.channelName!),
      ),
    );
  }

  Future<bool> checkPermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    return statuses[Permission.camera] == PermissionStatus.granted &&
        statuses[Permission.microphone] == PermissionStatus.granted;
  }
}
