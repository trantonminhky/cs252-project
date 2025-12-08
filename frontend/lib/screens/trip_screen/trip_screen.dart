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
import "package:virtour_frontend/frontend_service_layer/place_service.dart";
import "package:virtour_frontend/global/userinfo.dart";

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
        // Call the backend API to create the event
        final regionService = RegionService();
        final apiResult = await regionService.createEvent(
          name: newEvent.name,
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

          // Subscribe the user to the event
          final userInfo = UserInfo();
          final username =
              userInfo.email.isNotEmpty ? userInfo.email : 'guest';
          await regionService.subscribeToEvent(
              username, apiResult['id'].toString());

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
    final placesAsync = ref.watch(tripProvider);
    final participatedEventsAsync = ref.watch(participatedEventsProvider);

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
              Expanded(
                child: placesAsync.when(
                  data: (places) {
                    return participatedEventsAsync.when(
                      data: (events) {
                        final hasContent =
                            places.isNotEmpty || events.isNotEmpty;

                        if (!hasContent) {
                          return Center(
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
                                          backgroundColor:
                                              const Color(0xffd72323),
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(13),
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
                                            borderRadius:
                                                BorderRadius.circular(13),
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
                          );
                        }

                        return const TripScreenContent();
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error loading events: $error'),
                            TextButton(
                              onPressed: () => ref
                                  .read(participatedEventsProvider.notifier)
                                  .refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading places: $error'),
                        TextButton(
                          onPressed: () =>
                              ref.read(tripProvider.notifier).refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
