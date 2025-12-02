import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingService {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;

  AudioRecordingService();

  Future<void> _initRecorder() async {
    if (_isRecorderInitialized) return;
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
    _isRecorderInitialized = true;
  }

  Future<bool> requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<void> startRecording() async {
    await _initRecorder();

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/watch_voice_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _audioRecorder!.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );
  }

  Future<String?> stopRecording() async {
    if (_audioRecorder == null || !_audioRecorder!.isRecording) return null;

    final path = await _audioRecorder!.stopRecorder();
    return path;
  }

  void dispose() {
    _audioRecorder?.closeRecorder();
  }
}
