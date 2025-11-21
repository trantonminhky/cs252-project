import "package:flutter/material.dart";

enum CardSize { list, vert, horiz }

class Cards extends StatelessWidget {
  final CardSize size;
  final String imageUrl;
  final String title;
  final String? subtitle;
  final List<({String label, Color backgroundColor})> chips;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const Cards({
    Key? key,
    required this.size,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    required this.chips,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return switch (size) {
      CardSize.list => _buildListCard(context),
      CardSize.vert => _buildVertCard(context),
      CardSize.horiz => _buildHorizCard(context),
    };
  }

  // List variant - horizontal layout with image on left
  Widget _buildListCard(BuildContext context) {
    // Check if the image is an asset or network image
    final bool isAssetImage =
        imageUrl.startsWith('../assets/') || imageUrl.startsWith('assets/');
    final String cleanedImageUrl = imageUrl.replaceFirst('../', '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: isAssetImage
                  ? Image.asset(
                      cleanedImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            // Chips
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: chips
                    .map(
                      (chip) => Chip(
                        label: Text(
                          chip.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: chip.backgroundColor,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vert variant - vertical layout with image on top
  Widget _buildVertCard(BuildContext context) {
    // Check if the image is an asset or network image
    final bool isAssetImage =
        imageUrl.startsWith('../assets/') || imageUrl.startsWith('assets/');
    final String cleanedImageUrl = imageUrl.replaceFirst('../', '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with heart icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: isAssetImage
                      ? Image.asset(
                          cleanedImageUrl,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 160,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        )
                      : Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 160,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                ),
                // Heart icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: chips
                        .map(
                          (chip) => Chip(
                            label: Text(
                              chip.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: chip.backgroundColor,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Horiz variant - horizontal layout with full-width image on top
  Widget _buildHorizCard(BuildContext context) {
    // Check if the image is an asset or network image
    final bool isAssetImage =
        imageUrl.startsWith('../assets/') || imageUrl.startsWith('assets/');
    final String cleanedImageUrl = imageUrl.replaceFirst('../', '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-width image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: isAssetImage
                  ? Image.asset(
                      cleanedImageUrl,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 120,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 120,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
