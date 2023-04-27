import 'dart:io';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  DateTime _startTime = DateTime.now();
  int _duration = 0;
  bool _isRecording = false;
  final _elapsedTimeController = StreamController<Duration>.broadcast();

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
        Timer.periodic(
          Duration(seconds: 1),
          (timer) {
            if (!_isRecording) {
              timer.cancel();
            } else {
              _elapsedTimeController.add(
                DateTime.now().difference(_startTime),
              );
            }
          },
        );
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
    if (_isRecording) {
      try {
        _duration += DateTime.now().difference(_startTime).inSeconds;
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
    return _duration;
  }

  Future<int> pauseRecording() async {
    if (_isRecording) {
      try {
        _duration += DateTime.now().difference(_startTime).inSeconds;
        await _recorder?.pauseRecorder();
        _isRecording = false;
        print("Recording paused");
      } catch (e) {
        print("Error pausing recording: $e");
        throw RecordingException('Error pausing recording: $e');
      }
    } else {
      throw RecordingException('Not recording');
    }
    return _duration;
  }

  Future<void> resumeRecording() async {
    if (!_isRecording) {
      try {
        await _recorder?.resumeRecorder();
        _startTime = DateTime.now();
        _isRecording = true;
        print("Recording resumed");
      } catch (e) {
        print("Error resuming recording: $e");
        throw RecordingException('Error resuming recording: $e');
      }
    } else {
      throw RecordingException('Already recording');
    }
  }

  bool get isRecording => _isRecording;
  Stream<Duration> get elapsedTimeStream => _elapsedTimeController.stream;
}

class RecordingException implements Exception {
  final String message;

  RecordingException(this.message);

  @override
  String toString() => 'RecordingException: $message';
}
