import "package:flutter/material.dart";

enum BriefingSize { full, vert, horiz }

class Briefing extends StatelessWidget {
  const Briefing({
    super.key,
    required this.size,
    this.title = '',
    this.subtitle = '',
    this.category = '',
    this.imageUrl,
  });

  final BriefingSize size;
  final String title;
  final String subtitle;
  final String category;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    switch (size) {
      case BriefingSize.horiz:
        return _buildHorizontalBriefing();
      case BriefingSize.vert:
        return _buildVerticalBriefing();
      case BriefingSize.full:
        return _buildFullBriefing();
    }
  }

  Widget _buildHorizontalBriefing() {
    final bool isAssetImage = imageUrl?.startsWith('../assets/') ??
        imageUrl?.startsWith('assets/') ??
        false;
    final String? cleanedImageUrl = imageUrl?.replaceFirst('../', '');
    final ImageProvider imageProvider = isAssetImage
        ? AssetImage(cleanedImageUrl!)
        : NetworkImage(imageUrl ?? "https://via.placeholder.com/372x167")
            as ImageProvider;

    return Container(
      width: 372,
      height: 167,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -10,
            top: -10,
            child: Container(
              width: 392,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Container(
                    width: double.infinity,
                    height: 167,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 18,
                          top: 98,
                          child: SizedBox(
                            width: 330,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    title.isNotEmpty
                                        ? title
                                        : 'Bà Thiên Hậu Pagoda',
                                    style: const TextStyle(
                                      color: Color(0xFFF6F6F6),
                                      fontSize: 24,
                                      fontFamily: 'Oswald',
                                      fontWeight: FontWeight.w500,
                                      height: 1.17,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 330,
                                  height: 32,
                                  child: Text(
                                    subtitle.isNotEmpty
                                        ? subtitle
                                        : '710 Nguyễn Trãi, Phường 11, Quận 5, Thành phố Hồ Chí Minh, Vietnam',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Be Vietnam',
                                      fontWeight: FontWeight.w400,
                                      height: 1.33,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBriefing() {
    final bool isAssetImage = imageUrl?.startsWith('../assets/') ??
        imageUrl?.startsWith('assets/') ??
        false;
    final String? cleanedImageUrl = imageUrl?.replaceFirst('../', '');
    final ImageProvider imageProvider = isAssetImage
        ? AssetImage(cleanedImageUrl!)
        : NetworkImage(imageUrl ?? "https://via.placeholder.com/176x300")
            as ImageProvider;

    return Container(
      width: 176,
      height: 300,
      padding: const EdgeInsets.only(
        top: 16,
        left: 12,
        right: 28,
        bottom: 16,
      ),
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          SizedBox(
            width: 141,
            child: Text(
              title.isNotEmpty ? title : 'Sài Gòn',
              style: const TextStyle(
                color: Color(0xFFF6F6F6),
                fontSize: 24,
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w500,
                height: 1.17,
              ),
            ),
          ),
          if (category.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFF6165),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 5,
                        offset: Offset(0, 1),
                        spreadRadius: -363,
                      )
                    ],
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Be Vietnam',
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFullBriefing() {
    final bool isAssetImage = imageUrl?.startsWith('../assets/') ??
        imageUrl?.startsWith('assets/') ??
        false;
    final String? cleanedImageUrl = imageUrl?.replaceFirst('../', '');
    final ImageProvider imageProvider = isAssetImage
        ? AssetImage(cleanedImageUrl!)
        : NetworkImage(imageUrl ?? "https://via.placeholder.com/372x300")
            as ImageProvider;

    return Container(
      width: 372,
      height: 300,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Container(
        width: 372,
        height: 300,
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 16),
        decoration: ShapeDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF6F6F6),
                  fontSize: 36,
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.w500,
                  height: 1.17,
                ),
              ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
