class PoseEntry {
  final int? id;
  final String keypointsJson;
  final String timestamp;
  final String imagePath;
  final String? imageUrl;

  PoseEntry({this.id, required this.keypointsJson, required this.timestamp, required this.imagePath, this.imageUrl});

  Map<String, dynamic> toMap() => {
    'id': id,
    'keypointsJson': keypointsJson,
    'timestamp': timestamp,
    'imagePath': imagePath,
    'imageUrl': imageUrl,
  };

  factory PoseEntry.fromMap(Map<String, dynamic> map) => PoseEntry(
    id: map['id'],
    keypointsJson: map['keypointsJson'],
    timestamp: map['timestamp'],
    imagePath: map['imagePath'],
    imageUrl: map['imageUrl'],
  );
}