import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/recording.dart';

typedef SaveCallback = Future<void> Function(Recording recording);

class EditDialog extends StatefulWidget {
  final Recording recording;
  final SaveCallback onSave;
  final SaveCallback onDelete;

  EditDialog({
    required this.recording,
    required this.onSave,
    required this.onDelete,
  });

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  TextEditingController? _titleController;
  TextEditingController? _scoreController;
  int? _favoriteValue;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recording.title);
    _scoreController =
        TextEditingController(text: max(widget.recording.score, 0).toString());
    _favoriteValue = widget.recording.favorite;
  }

  @override
  void dispose() {
    _titleController!.dispose();
    _scoreController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Recording'),
      content: SingleChildScrollView(
          child: Column(children: [
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
          initialRating: _favoriteValue!.toDouble(),
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
      ])),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () async {
            widget.recording.title = _titleController!.text;
            widget.recording.score = int.parse(_scoreController!.text);
            widget.recording.favorite = _favoriteValue!;
            await widget.onSave(widget.recording);
            Navigator.pop(context);
          },
        ),
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
                await widget.onDelete(widget.recording);
                Navigator.pop(context);
              }
            })
      ],
    );
  }
}
