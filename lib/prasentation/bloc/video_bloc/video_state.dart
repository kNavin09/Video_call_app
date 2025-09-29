abstract class VideoCallState {
  final bool isJoined;
  final int? remoteUid;
  final bool muteAudio;
  final bool disableVideo;
  final bool isScreenSharing;
  final String? channelName;

  const VideoCallState({
    required this.isJoined,
    required this.remoteUid,
    required this.muteAudio,
    required this.disableVideo,
    this.isScreenSharing = false,
    this.channelName,
  });
}

class VideoCallActive extends VideoCallState {
  const VideoCallActive({
    required bool isJoined,
    required int? remoteUid,
    required bool muteAudio,
    required bool disableVideo,
    bool isScreenSharing = false,
    String? channelName,
  }) : super(
          isJoined: isJoined,
          remoteUid: remoteUid,
          muteAudio: muteAudio,
          disableVideo: disableVideo,
          isScreenSharing: isScreenSharing,
          channelName: channelName,
        );

  VideoCallActive copyWith({
    bool? isJoined,
    int? remoteUid,
    bool? muteAudio,
    bool? disableVideo,
    bool? isScreenSharing,
    String? channelName,
  }) {
    return VideoCallActive(
      isJoined: isJoined ?? this.isJoined,
      remoteUid: remoteUid ?? this.remoteUid,
      muteAudio: muteAudio ?? this.muteAudio,
      disableVideo: disableVideo ?? this.disableVideo,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      channelName: channelName ?? this.channelName,
    );
  }
}

class VideoCallInitial extends VideoCallState {
  const VideoCallInitial()
      : super(
          isJoined: false,
          remoteUid: null,
          muteAudio: false,
          disableVideo: false,
          isScreenSharing: false,
        );
}
