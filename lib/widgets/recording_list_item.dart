import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:karareco/models/recording.dart';
import 'package:karareco/utils/date_manager.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'edit_dialog.dart';

class RecordingListItem extends StatelessWidget {
  Recording recording;
  final AudioPlayer player;

  RecordingListItem({required this.recording, required this.player});

  void _playAudio() async {
    await player.setFilePath(recording.filePath);
    player.play();
  }

  Future<void> _showEditDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => EditDialog(
        recording: recording,
        onSave: (Recording recording) async {
          Hive.box<dynamic>('recordings').put(recording.id, recording);
        },
        onDelete: (Recording recording) async {
          Hive.box<dynamic>('recordings').delete(recording.id);
        },
      ),
    );
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
                      DateManager.getFormattedDateTime(recording.dateTime),
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
