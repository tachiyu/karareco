import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:karareco/screens/recording_screen.dart';
import 'package:karareco/screens/search_screen.dart';
import 'package:karareco/widgets/recording_list_item.dart';
import 'package:karareco/widgets/playback_controls.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _player = AudioPlayer();
  String? _searchedTitle;
  int? _searchedRating;

  void _navigateToRecordingScreen(BuildContext context) async {
    // Navigate to the recording screen
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecordingScreen()),
    );
  }

  void _navigateToSearchScreen(BuildContext context) async {
    // Navigate to the search screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );
    if (result != null) {
      setState(() {
        _searchedTitle = result['title'] as String?;
        _searchedRating = result['rating'] as int?;
      });
    }
  }

  bool _filter(dynamic recording) {
    if (_searchedTitle != null && _searchedTitle!.isNotEmpty) {
      if (!recording.title.contains(_searchedTitle!)) {
        return false;
      }
    }
    if (_searchedRating != null) {
      if (recording.score < _searchedRating) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _navigateToSearchScreen(context),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: FutureBuilder(
            future: Hive.openBox<dynamic>('recordings'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                return ValueListenableBuilder(
                  valueListenable: Hive.box<dynamic>('recordings').listenable(),
                  builder: (context, Box<dynamic> box, _) {
                    if (box.values.isEmpty) {
                      return const Center(
                        child: Text('No recordings yet'),
                      );
                    }
                    final fiteredRecordings =
                        box.values.where(_filter).toList();
                    return ListView.builder(
                      itemCount: fiteredRecordings.length,
                      itemBuilder: (context, index) {
                        final recording = fiteredRecordings[index];
                        return RecordingListItem(
                          recording: recording!,
                          player: _player,
                        );
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        PlaybackControls(player: _player),
      ]),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.mic),
          onPressed: () => _navigateToRecordingScreen(context)),
    );
  }
}
