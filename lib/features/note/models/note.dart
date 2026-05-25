class Note {
  final String id;
  final String heading;
  final String body;
  final int colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.heading,
    required this.body,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'heading': heading,
        'body': body,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        heading: json['heading'] as String,
        body: json['body'] as String,
        colorHex: json['colorHex'] as int,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(), // Backwards compatible fallback
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Note copyWith({
    String? heading,
    String? body,
    int? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      heading: heading ?? this.heading,
      body: body ?? this.body,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
