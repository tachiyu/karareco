import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:karareco/models/recording.dart';
import 'package:karareco/utils/date_manager.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RecordingListItem extends StatelessWidget {
  Recording recording;
  final AudioPlayer player;

  RecordingListItem({required this.recording, required this.player});

  void _playAudio() async {
    await player.setFilePath(recording.filePath);
    player.play();
  }

  Future<void> _showEditDialog(BuildContext context) async {
    TextEditingController _titleController =
        TextEditingController(text: recording.title);
    TextEditingController _scoreController =
        TextEditingController(text: max(recording.score, 0).toString());
    int _favoriteValue = recording.favorite;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Edit Recording'),
              content: SingleChildScrollView(
                  child: Column(
                children: [
                  // Form fields go here
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  TextFormField(
                    controller: _scoreController,
                    decoration: const InputDecoration(
                      labelText: 'Score',
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: _favoriteValue.toDouble(),
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 30,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      _favoriteValue = rating.toInt();
                    },
                  ),
                ],
              )),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                    child: const Text('Save'),
                    onPressed: () async {
                      recording.title = _titleController.text;
                      recording.score = int.parse(_scoreController.text);
                      recording.favorite = _favoriteValue;
                      final recordingBox = Hive.box<dynamic>('recordings');
                      await recordingBox.put(recording.id, recording);
                      Navigator.of(context).pop();
                    }),
                TextButton(
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      bool deleteConfirmed = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete Confirmation"),
                            content: const Text(
                                "Are you sure you want to delete this recording?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: const Text("Delete"),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          );
                        },
                      );
                      if (deleteConfirmed) {
                        print(
                            "delete ${recording.id}, ${Hive.isBoxOpen('recordings')}");
                        final recordingBox = Hive.box<dynamic>('recordings');
                        await recordingBox.delete(recording.id);
                      }
                      Navigator.of(context).pop();
                    })
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: _playAudio,
        onLongPress: () => _showEditDialog(context),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      DateManager.getFormattedDateTime(recording.id),
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              recording.title.isEmpty ? '***' : recording.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 16.0),
                            )),
                        Text(
                          'Score: ${recording.score < 0 ? ' --' : recording.score.toString().padLeft(3, ' ')}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 40.0,
              ),
              Text(
                '${recording.duration ~/ 60}:${(recording.duration % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ));
  }
}
