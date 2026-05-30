import 'package:flutter/material.dart';
import '../models/alamat_model.dart';

class ChapterTile extends StatelessWidget {
  final ChapterModel chapter;
  final String language;
  final bool isRead;
  final Color catColor;
  final VoidCallback onTap;

  const ChapterTile({
    super.key,
    required this.chapter,
    required this.language,
    required this.isRead,
    required this.catColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = language == 'fil' ? chapter.titleFil : chapter.titleEng;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isRead ? catColor : catColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: catColor.withOpacity(0.4)),
        ),
        child: Center(
          child: isRead
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : Text(
                  '${chapter.chapter}',
                  style: TextStyle(
                    color: catColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isRead ? Colors.white : Colors.white.withOpacity(0.85),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: catColor.withOpacity(0.6),
      ),
    );
  }
}