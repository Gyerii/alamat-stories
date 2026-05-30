class ChapterModel {
  final int chapter;
  final String titleFil;
  final String titleEng;
  final String textFil;
  final String textEng;

  ChapterModel({
    required this.chapter,
    required this.titleFil,
    required this.titleEng,
    required this.textFil,
    required this.textEng,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      chapter: json['chapter'] ?? 1,
      titleFil: json['title_fil'] ?? '',
      titleEng: json['title_eng'] ?? '',
      textFil: json['text_fil'] ?? '',
      textEng: json['text_eng'] ?? '',
    );
  }
}

class AlamatModel {
  final String id;
  final String region;
  final String category;
  final String emoji;
  final String image;
  final String titleFil;
  final String titleEng;
  final List<ChapterModel> chapters;

  AlamatModel({
    required this.id,
    required this.region,
    required this.category,
    required this.emoji,
    required this.image,
    required this.titleFil,
    required this.titleEng,
    required this.chapters,
  });

  factory AlamatModel.fromJson(Map<String, dynamic> json) {
    return AlamatModel(
      id: json['id'] ?? '',
      region: json['region'] ?? '',
      category: json['category'] ?? '',
      emoji: json['emoji'] ?? '📖',
      image: json['image'] ?? '',
      titleFil: json['title_fil'] ?? '',
      titleEng: json['title_eng'] ?? '',
      chapters: (json['chapters'] as List<dynamic>? ?? [])
          .map((c) => ChapterModel.fromJson(c))
          .toList(),
    );
  }
}