import 'package:hive/hive.dart';

part 'recording.g.dart';

@HiveType(typeId: 0)
class Recording {
  @HiveField(0)
  final int id;
  @HiveField(1)
  String title;
  @HiveField(2)
  int score;
  @HiveField(3)
  int favorite;
  @HiveField(4)
  final String filePath;
  @HiveField(5)
  final int duration;
  @HiveField(6)
  final int dateTime;

  Recording({
    required this.id,
    required this.title,
    required this.score,
    required this.favorite,
    required this.filePath,
    required this.duration,
    required this.dateTime,
  });
}

// class RecordingAdapter extends TypeAdapter<Recording> {
//   @override
//   final typeId = 0;

//   @override
//   Recording read(BinaryReader reader) {
//     return Recording(
//       id: reader.readInt(),
//       title: reader.readString(),
//       score: reader.readInt(),
//       favorite: reader.readInt(),
//       filePath: reader.readString(),
//       duration: reader.readInt(),
//       dateTime: reader.readInt(),
//     );
//   }

//   @override
//   void write(BinaryWriter writer, Recording obj) {
//     writer.writeInt(obj.id);
//     writer.writeString(obj.title);
//     writer.writeInt(obj.score);
//     writer.writeInt(obj.favorite);
//     writer.writeString(obj.filePath);
//     writer.writeInt(obj.duration);
//     writer.writeInt(obj.dateTime);
//   }
// }
