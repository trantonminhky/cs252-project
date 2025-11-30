import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:virtour_frontend/components/custom_text_field.dart';
import 'package:virtour_frontend/screens/data_factories/event.dart';

class CreateEventForm extends StatefulWidget {
  const CreateEventForm({super.key});

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _numberOfPeopleController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6165),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFF6165),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        time: _selectedDateTime,
        imageUrl: _imageUrlController.text.isEmpty
            ? "../assets/images/places/Saigon.png"
            : _imageUrlController.text,
        numberOfPeople: int.tryParse(_numberOfPeopleController.text) ?? 0,
      );

      Navigator.of(context).pop(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Create Event",
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: "BeVietnamPro",
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Name
                      MyTextField(
                        textEditingController: _nameController,
                        label: "Event Name",
                        hintText: "Enter event name",
                      ),
                      const SizedBox(height: 16),

                      // Location
                      MyTextField(
                        textEditingController: _locationController,
                        label: "Location",
                        hintText: "Enter location",
                      ),
                      const SizedBox(height: 16),

                      // Description
                      MyTextField(
                        textEditingController: _descriptionController,
                        label: "Description",
                        hintText: "Enter event description",
                      ),
                      const SizedBox(height: 16),

                      // Date and Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              "Date & Time",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: "BeVietnamPro",
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => _selectDateTime(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMM dd, yyyy - HH:mm')
                                        .format(_selectedDateTime),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: "BeVietnamPro",
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Image URL
                      MyTextField(
                        textEditingController: _imageUrlController,
                        label: "Image URL (Optional)",
                        hintText: "Enter image URL or leave blank",
                      ),
                      const SizedBox(height: 16),

                      // Number of People
                      MyTextField(
                        textEditingController: _numberOfPeopleController,
                        label: "Expected Participants",
                        hintText: "Enter number of participants",
                        digitsOnly: true,
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFD72323),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          onPressed: _submitForm,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Create Event",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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
          ],
        ),
      ),
    );
  }
}
