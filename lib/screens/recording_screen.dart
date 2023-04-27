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

    // Prompt user to enter title and score
    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController _titleController = TextEditingController();
          TextEditingController _scoreController = TextEditingController();
          return AlertDialog(
            title: const Text('Enter title and score'),
            content: SingleChildScrollView(
              child: Column(children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: _scoreController,
                  decoration: const InputDecoration(
                    labelText: 'Score',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ]),
            ),
            actions: [
              TextButton(
                  child: const Text("Save"),
                  onPressed: () async {
                    // Save recording
                    final box = await Hive.openBox<dynamic>('recordings');
                    final recording = Recording(
                      id: box.length,
                      dateTime: DateTime.now().millisecondsSinceEpoch,
                      title: _titleController.text,
                      score: int.parse(_scoreController.text),
                      favorite: 0,
                      filePath: _currentRecordingPath!,
                      duration: duration,
                    );
                    box.put(recording.id, recording);

                    // Close dialog and navigate back to the home screen
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  void _pauseRecording() async {
    await _recorder.pauseRecording();
  }

  void _resumeRecording() async {
    await _recorder.resumeRecording();
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
            StreamBuilder<Duration>(
              stream: _recorder.elapsedTimeStream,
              builder: (context, snapshot) {
                final elapsedTime = snapshot.data ?? Duration.zero;
                return Text(
                  '${elapsedTime.inMinutes.toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 40.0),
                );
              },
            ),
            _currentRecordingPath == null
                ? IconButton(
                    iconSize: 100.0,
                    icon: const Icon(
                      Icons.radio_button_checked_rounded,
                      color: Colors.red,
                    ),
                    onPressed: _startRecording,
                  )
                : IconButton(
                    iconSize: 100.0,
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                      color: Colors.black,
                    ),
                    onPressed: _stopRecording,
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
