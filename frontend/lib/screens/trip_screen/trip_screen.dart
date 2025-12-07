import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/frontend_service_layer/event_service.dart";
import "package:virtour_frontend/providers/event_provider.dart";
import "package:virtour_frontend/providers/participated_events_provider.dart";
import "package:virtour_frontend/screens/trip_screen/trip_screen_content.dart";
import "package:virtour_frontend/screens/trip_screen/create_options_dialog.dart";
import "package:virtour_frontend/screens/trip_screen/create_event_form.dart";
import "package:virtour_frontend/screens/data_factories/event.dart";

class TripScreen extends ConsumerWidget {
  const TripScreen({super.key});

  Future<void> _showCreateOptions(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const CreateOptionsDialog(),
    );

    if (result == 'event' && context.mounted) {
      final Event? newEvent = await showDialog<Event>(
        context: context,
        builder: (context) => const CreateEventForm(),
      );

      if (newEvent != null) {
        final apiResult = await EventService().createEvent(
          name: newEvent.name,
          location: newEvent.location,
          description: newEvent.description,
          imageLink: newEvent.imageUrl,
          startTime: newEvent.startTime.millisecondsSinceEpoch,
          endTime: newEvent.endTime.millisecondsSinceEpoch,
        );

        if (apiResult != null && context.mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Event "${newEvent.name}" created successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          await EventService().subscribeToEvent(apiResult["id"]);

          // Refresh participated events and all events
          ref.read(participatedEventsProvider.notifier).refresh();
          ref.read(eventsProvider.notifier).refresh();
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create event'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else if (result == 'trip' && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Browse places and add them to your Saves!'),
          duration: Duration(seconds: 2),
        ),
      );
      // The trip functionality is handled through the existing Saves system
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My trips",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: "BeVietnamPro",
                      fontWeight: FontWeight.w700,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  // Always show create button
                  IconButton(
                    onPressed: () => _showCreateOptions(context, ref),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD72323),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(
                child: TripScreenContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
