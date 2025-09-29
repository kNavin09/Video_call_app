import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  late final RtcEngine _engine;
  bool _isEngineInitialized = false;

  RtcEngine get engine => _engine;

  static const appId = 'f88792268c3340ff8a916772116e6d3a';
  //change token mannualy 
  static const token =
      '007eJxTYJhofX2GFpfR6+UXPVfIfxaRvXTNxs8r+X1Um/KGF1LWp1sUGNIsLMwtjYzMLJKNjU0M0tIsEi0NzczNjQwNzVLNUowTH8neymgIZGS4xKTNysgAgSA+C0NRfn4uAwMACigeSQ==';

  VideoCallBloc() : super(const VideoCallInitial()) {
    on<JoinCall>(_onJoinCall);
    on<LeaveCall>(_onLeaveCall);
    on<ToggleMute>(_onToggleMute);
    on<ToggleVideo>(_onToggleVideo);
    on<SwitchCamera>(_onSwitchCamera);
    on<StartScreenShare>(_onStartScreenShare);
    on<StopScreenShare>(_onStopScreenShare);

    on<LocalUserJoined>((event, emit) => _updateActiveState(emit, (s) => s.copyWith(isJoined: true)));
    on<RemoteUserJoined>((event, emit) => _updateActiveState(emit, (s) => s.copyWith(remoteUid: event.uid)));
    on<RemoteUserLeft>((event, emit) async {
      if (_isEngineInitialized) {
        await _engine.leaveChannel();
        await _engine.release();
        _isEngineInitialized = false;
      }
      emit(const VideoCallInitial());
    });
  }

  /// Helper to safely update VideoCallActive state
  void _updateActiveState(Emitter<VideoCallState> emit, VideoCallActive Function(VideoCallActive) updater) {
    if (state is VideoCallActive) {
      emit(updater(state as VideoCallActive));
    }
  }

  int generateUid() => Random().nextInt(999999) + 1;

  Future<void> _onJoinCall(JoinCall event, Emitter<VideoCallState> emit) async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    _isEngineInitialized = true;

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (_, __) => add(LocalUserJoined()),
        onUserJoined: (_, uid, __) => add(RemoteUserJoined(uid)),
        onUserOffline: (_, __, ___) => add(RemoteUserLeft()),
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: event.channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );

    emit(VideoCallActive(
      isJoined: true,
      remoteUid: null,
      muteAudio: false,
      disableVideo: false,
      channelName: event.channelId,
    ));
  }

  Future<void> _onLeaveCall(LeaveCall event, Emitter<VideoCallState> emit) async {
    if (_isEngineInitialized) {
      await _engine.leaveChannel();
      await _engine.release();
      _isEngineInitialized = false;
    }
    emit(const VideoCallInitial());
  }

  Future<void> _onToggleMute(ToggleMute event, Emitter<VideoCallState> emit) async {
    if (!_ensureActiveState()) return;
    final current = state as VideoCallActive;
    final newMute = !current.muteAudio;
    await _engine.muteLocalAudioStream(newMute);
    emit(current.copyWith(muteAudio: newMute));
  }

  Future<void> _onToggleVideo(ToggleVideo event, Emitter<VideoCallState> emit) async {
    if (!_ensureActiveState()) return;
    final current = state as VideoCallActive;
    final newDisable = !current.disableVideo;
    await _engine.muteLocalVideoStream(newDisable);
    emit(current.copyWith(disableVideo: newDisable));
  }

  Future<void> _onSwitchCamera(SwitchCamera event, Emitter<VideoCallState> emit) async {
    if (!_ensureActiveState()) return;
    try {
      await _engine.switchCamera();
      print("📷 Camera switched");
    } catch (e) {
      print("❌ Failed to switch camera: $e");
    }
  }

  Future<void> _onStartScreenShare(StartScreenShare event, Emitter<VideoCallState> emit) async {
    if (!_ensureActiveState()) return;
    final current = state as VideoCallActive;

    try {
      await _engine.startScreenCapture(
        ScreenCaptureParameters2(
          videoParams: ScreenVideoParameters(
            dimensions: VideoDimensions(width: event.screenWidth, height: event.screenHeight),
            frameRate: 15,
            bitrate: 1000,
          ),
        ),
      );

      emit(current.copyWith(isScreenSharing: true, disableVideo: true));
      print("✅ Screen sharing started");
    } catch (e) {
      print("❌ Screen share failed: $e");
    }
  }

  Future<void> _onStopScreenShare(StopScreenShare event, Emitter<VideoCallState> emit) async {
    if (!_ensureActiveState()) return;
    final current = state as VideoCallActive;
    await _engine.stopScreenCapture();
    emit(current.copyWith(isScreenSharing: false, disableVideo: false));
  }

  /// Ensures the engine is initialized and state is active
  bool _ensureActiveState() => _isEngineInitialized && state is VideoCallActive;
}
