import 'package:flutter/material.dart';

class CreateOptionsDialog extends StatelessWidget {
  const CreateOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Create",
              style: TextStyle(
                fontSize: 24,
                fontFamily: "BeVietnamPro",
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "What would you like to create?",
              style: TextStyle(
                fontSize: 14,
                fontFamily: "BeVietnamPro",
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 24),

            // Create a Trip Option
            _buildOptionCard(
              context,
              icon: Icons.add_location_alt_outlined,
              title: "Create a Trip",
              description: "Add places to your saved collection",
              onTap: () {
                Navigator.of(context).pop('trip');
              },
            ),
            const SizedBox(height: 16),

            // Create an Event Option
            _buildOptionCard(
              context,
              icon: Icons.event_outlined,
              title: "Create an Event",
              description: "Organize and share a cultural event",
              onTap: () {
                Navigator.of(context).pop('event');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6165).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFFFF6165),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "BeVietnamPro",
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: "BeVietnamPro",
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }
}
