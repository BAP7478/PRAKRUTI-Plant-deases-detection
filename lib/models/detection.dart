class Detection {
  final String disease;
  final double confidence;
  final DateTime dateTime;
  final String imagePath;

  Detection({
    required this.disease,
    required this.confidence,
    required this.dateTime,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'disease': disease,
      'confidence': confidence,
      'dateTime': dateTime.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      disease: json['disease'] as String,
      confidence: json['confidence'] as double,
      dateTime: DateTime.parse(json['dateTime'] as String),
      imagePath: json['imagePath'] as String,
    );
  }
}
