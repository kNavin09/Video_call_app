
abstract class VideoCallEvent {}

class JoinCall extends VideoCallEvent {
  final String channelId;
  JoinCall({required this.channelId});
}

class LeaveCall extends VideoCallEvent {}

class ToggleMute extends VideoCallEvent {}

class ToggleVideo extends VideoCallEvent {}

class LocalUserJoined extends VideoCallEvent {}

class RemoteUserJoined extends VideoCallEvent {
  final int uid;
  RemoteUserJoined(this.uid);
}
class SwitchCamera extends VideoCallEvent {}


class RemoteUserLeft extends VideoCallEvent {}
class StartScreenShare extends VideoCallEvent {
  final int screenWidth;
  final int screenHeight;

  StartScreenShare({required this.screenWidth, required this.screenHeight});
}class StopScreenShare extends VideoCallEvent {}
