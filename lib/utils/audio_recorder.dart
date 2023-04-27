import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  DateTime _startTime = DateTime.now();
  bool _isRecording = false;

  Future<void> init() async {
    try {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      print("Recorder initialized: ${_recorder != null}");
    } catch (e) {
      print("Error initializing recorder: $e");
    }
  }

  Future<void> dispose() async {
    try {
      await _recorder!.closeRecorder();
      print("Recorder disposed");
    } catch (e) {
      print("Error disposing recorder: $e");
    } finally {
      _recorder = null;
    }
  }

  Future<String> startRecording() async {
    if (!_isRecording) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final recordingDir = Directory('${appDocDir.path}/recordings');
        if (!await recordingDir.exists()) {
          await recordingDir.create();
        }
        final path =
            '${recordingDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

        print("Recording path: $path");

        await _recorder?.startRecorder(
          toFile: path,
          codec: Codec.aacADTS,
        );
        _startTime = DateTime.now();
        _isRecording = true;
        return path;
      } catch (e) {
        print("Error starting recording: $e");
        throw RecordingException('Error starting recording: $e');
      }
    } else {
      throw RecordingException('Already recording');
    }
  }

  Future<int> stopRecording() async {
    int durationSec = 0;
    if (_isRecording) {
      try {
        durationSec = DateTime.now().difference(_startTime).inSeconds;
        final path = await _recorder?.stopRecorder();
        _isRecording = false;
        print("Recording stopped. File path: $path");
      } catch (e) {
        print("Error stopping recording: $e");
        throw RecordingException('Error stopping recording: $e');
      }
    } else {
      throw RecordingException('Not recording');
    }
    return durationSec;
  }

  bool get isRecording => _isRecording;
}

class RecordingException implements Exception {
  final String message;

  RecordingException(this.message);

  @override
  String toString() => 'RecordingException: $message';
}
