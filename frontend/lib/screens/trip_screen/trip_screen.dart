import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:virtour_frontend/providers/trip_provider.dart";
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
        // Save event to provider
        ref.read(eventsProvider.notifier).addEvent(newEvent);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Event "${newEvent.name}" created successfully!'),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF4CAF50),
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
    final places = ref.watch(tripProvider);
    final participatedEvents = ref.watch(participatedEventsProvider);
    final hasContent = places.isNotEmpty || participatedEvents.isNotEmpty;

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
                  // Add Create button in header when there's content
                  if (hasContent)
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
              !hasContent
                  ? Expanded(
                      child: Center(
                        child: DottedBorder(
                          options: const RoundedRectDottedBorderOptions(
                            radius: Radius.circular(16),
                            dashPattern: <double>[3, 3],
                            strokeWidth: 2,
                          ),
                          child: SizedBox(
                            height: 279,
                            width: 372,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 21,
                                horizontal: 43,
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/icons/carbon_warning.png",
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Nothing here...",
                                    style: TextStyle(
                                      color: Color(0xffff6165),
                                      fontSize: 20,
                                      fontFamily: "BeVietnamPro",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xffd72323),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showCreateOptions(context, ref),
                                    child: const SizedBox(
                                      width: 277,
                                      height: 33,
                                      child: Center(
                                        child: Text(
                                          "Create",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: "BeVietnamPro",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: const SizedBox(
                                      width: 277,
                                      height: 33,
                                      child: Center(
                                        child: Text(
                                          "Create with AI",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: "BeVietnamPro",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Expanded(child: TripScreenContent()),
            ],
          ),
        ),
      ),
    );
  }
}
