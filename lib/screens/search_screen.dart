import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<StatefulWidget> {
  String? _selectedTitle;
  int? _selectedRating;

  List<String> _getTitles() {
    final box = Hive.box<dynamic>('recordings');
    Set<String> uniqueTitles = {};
    for (var recording in box.values) {
      uniqueTitles.add(recording.title);
    }
    return uniqueTitles.toList();
  }

  void _onSearch() {
    Navigator.pop(
        context, {'title': _selectedTitle, 'rating': _selectedRating});
  }

  @override
  Widget build(BuildContext context) {
    final titles = _getTitles();
    return Scaffold(
        appBar: AppBar(
          title: Text('Search'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButton<String>(
                hint: Text("Select a title"),
                value: _selectedTitle,
                items: titles.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedTitle = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              DropdownButton<int>(
                hint: Text("Select a rating"),
                value: _selectedRating,
                items: [1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedRating = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _onSearch,
                child: Text('Search'),
              ),
            ],
          ),
        ));
  }
}
