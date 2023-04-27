import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:karareco/models/recording.dart';
import 'package:karareco/utils/audio_recorder.dart';
import 'package:karareco/utils/permission_handler.dart';
import 'package:path/path.dart' as p;

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;

  @override
  void initState() {
    super.initState();
    _recorder.init();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  void _startRecording() async {
    // Request permissions
    bool permissionsGranted = await PermissionHandler().requestPermissions([
      'microphone',
      'storage',
    ]);
    // Start recording if permissions are granted
    if (!permissionsGranted) {
      return;
    }
    final audioFilePath = await _recorder.startRecording();
    setState(() {
      _currentRecordingPath = audioFilePath;
    });
  }

  void _stopRecording() async {
    // Stop recording
    final duration = await _recorder.stopRecording();
    // Save recording
    final box = await Hive.openBox<dynamic>('recordings');
    final recording = Recording(
      id: DateTime.now().millisecondsSinceEpoch,
      title: "",
      score: -1,
      favorite: 0,
      filePath: _currentRecordingPath!,
      duration: duration,
    );
    box.add(recording);
    // Navigate back to the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _currentRecordingPath == null
                ? ElevatedButton(
                    onPressed: _startRecording,
                    child: const Text('Start Recording'),
                  )
                : ElevatedButton(
                    onPressed: _stopRecording,
                    child: const Text('Stop Recording'),
                  ),
            const SizedBox(height: 20),
            _currentRecordingPath != null
                ? Text('Recording to: $_currentRecordingPath')
                : const Text('Not recording'),
          ],
        ),
      ),
    );
  }
}
