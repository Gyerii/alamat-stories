// ════════════════════════════════════════════════════════════
//  chapter_model.dart  &  alamat_model.dart  — combined file
//  I-split mo lang sa dalawang files kung kailangan.
// ════════════════════════════════════════════════════════════

class ChapterModel {
  final int chapter;
  final String titleFil;
  final String titleEng;
  final String textFil;
  final String textEng;

  const ChapterModel({
    required this.chapter,
    required this.titleFil,
    required this.titleEng,
    required this.textFil,
    required this.textEng,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      chapter:  (json['chapter']   as num?)?.toInt() ?? 1,
      titleFil: json['title_fil']  as String? ?? '',
      titleEng: json['title_eng']  as String? ?? '',
      textFil:  json['text_fil']   as String? ?? '',
      textEng:  json['text_eng']   as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'chapter':   chapter,
        'title_fil': titleFil,
        'title_eng': titleEng,
        'text_fil':  textFil,
        'text_eng':  textEng,
      };
}

// ─────────────────────────────────────────────────────────────

class AlamatModel {
  final String id;
  final String region;
  final String category;
  final String emoji;
  final String image;      // local cover path — populated by AlamatService
  final String titleFil;
  final String titleEng;
  final List<ChapterModel> chapters;

  const AlamatModel({
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
      id:       json['id']        as String? ?? '',
      region:   json['region']    as String? ?? '',
      category: json['category']  as String? ?? '',
      emoji:    json['emoji']     as String? ?? '📖',
      image:    json['image']     as String? ?? '',
      titleFil: json['title_fil'] as String? ?? '',
      titleEng: json['title_eng'] as String? ?? '',
      chapters: (json['chapters'] as List<dynamic>? ?? [])
          .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id':        id,
        'region':    region,
        'category':  category,
        'emoji':     emoji,
        'image':     image,
        'title_fil': titleFil,
        'title_eng': titleEng,
        'chapters':  chapters.map((c) => c.toJson()).toList(),
      };

  /// Returns a copy with a different image path (para sa cover caching)
  AlamatModel copyWithImage(String imagePath) => AlamatModel(
        id:       id,
        region:   region,
        category: category,
        emoji:    emoji,
        image:    imagePath,
        titleFil: titleFil,
        titleEng: titleEng,
        chapters: chapters,
      );

  /// Total chapters count — shortcut para sa UI
  int get chapterCount => chapters.length;

  /// First chapter text preview (para sa card subtitle kung kailangan)
  String get previewFil =>
      chapters.isNotEmpty ? chapters.first.textFil : '';

  String get previewEng =>
      chapters.isNotEmpty ? chapters.first.textEng : '';
}