import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:virtour_frontend/screens/data_factories/event.dart';
import 'package:virtour_frontend/providers/participated_events_provider.dart';
import 'package:virtour_frontend/screens/data_factories/data_service.dart';
import 'package:virtour_frontend/constants/userinfo.dart';

class EventDetailScreen extends ConsumerWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isParticipating =
        ref.watch(participatedEventsProvider).any((e) => e.id == event.id);

    final bool isAssetImage = event.imageUrl.startsWith('../assets/') ||
        event.imageUrl.startsWith('assets/');
    final String cleanedImageUrl = event.imageUrl.replaceFirst('../', '');
    final ImageProvider imageProvider = isAssetImage
        ? AssetImage(cleanedImageUrl)
        : NetworkImage(event.imageUrl) as ImageProvider;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Name
                        Text(
                          event.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontFamily: "BeVietnamPro",
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Start Time
                        _buildInfoRow(
                          Icons.calendar_today,
                          "Start Time",
                          DateFormat('EEEE, MMM dd, yyyy - HH:mm')
                              .format(event.startTime),
                        ),
                        const SizedBox(height: 16),

                        // End Time
                        _buildInfoRow(
                          Icons.access_time,
                          "End Time",
                          DateFormat('EEEE, MMM dd, yyyy - HH:mm')
                              .format(event.endTime),
                        ),
                        const SizedBox(height: 16),

                        // Location
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          "Location",
                          event.location,
                        ),
                        const SizedBox(height: 16),

                        // Participants
                        _buildInfoRow(
                          Icons.people_outline,
                          "Participants",
                          "${event.numberOfPeople} people",
                        ),
                        const SizedBox(height: 24),

                        // Description Section
                        const Text(
                          "About This Event",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "BeVietnamPro",
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "BeVietnamPro",
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 100), // Space for button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Participate Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFD72323),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: isParticipating
                  ? null
                  : () {
                      _showParticipateConfirmation(context, ref);
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  isParticipating ? "Already Participating" : "Participate",
                  style: TextStyle(
                    color: isParticipating ? Colors.grey : Colors.white,
                    fontSize: 18,
                    fontFamily: "BeVietnamPro",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6165).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFFFF6165),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showParticipateConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Confirm Participation",
          style: TextStyle(
            fontFamily: "BeVietnamPro",
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Do you want to participate in ${event.name}?",
          style: const TextStyle(
            fontFamily: "BeVietnamPro",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "BeVietnamPro",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFD72323),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final username = UserInfo().username;

              if (username.isEmpty) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please log in to participate in events'),
                    backgroundColor: Color(0xFFD72323),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              // Call backend to subscribe to event
              final success = await RegionService().subscribeToEvent(
                username,
                event.id.toString(),
              );

              if (!success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Failed to subscribe to event. Please try again.'),
                    backgroundColor: Color(0xFFD72323),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              // Add event to local state for immediate UI update
              ref.read(participatedEventsProvider.notifier).addEvent(event);

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully registered for ${event.name}!'),
                  backgroundColor: const Color(0xFF4CAF50),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Confirm",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "BeVietnamPro",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
