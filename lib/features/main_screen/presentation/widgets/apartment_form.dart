import 'package:apartment_survey_app/features/main_screen/presentation/widgets/survey_checklist.dart';
import 'package:apartment_survey_app/features/main_screen/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:apartment_survey_app/features/main_screen/application/apartment/apartment.dart';

class ApartmentForm extends StatefulWidget {
  final Apartment? initialApartment;
  const ApartmentForm({
    super.key,
    this.initialApartment,
  });

  @override
  State<ApartmentForm> createState() => _ApartmentFormState();
}

class _ApartmentFormState extends State<ApartmentForm> {
  String? selectedStatus;
  String? errorMessage;

  final TextEditingController blockController = TextEditingController();
  final TextEditingController doorNumberController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();
  final TextEditingController jobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialApartment != null) {
      blockController.text = widget.initialApartment!.block;
      doorNumberController.text = widget.initialApartment!.doorNumber
          .toString();
      interestsController.text = widget.initialApartment!.interests ?? "";
      jobController.text = widget.initialApartment!.job ?? "";
      selectedStatus = widget.initialApartment!.status;
    }
  }

  @override
  void dispose() {
    blockController.dispose();
    doorNumberController.dispose();
    interestsController.dispose();
    jobController.dispose();

    super.dispose();
  }

  void _saveApartment() {
    String block;
    int? nums;
    String hobbies;
    String job;
    block = blockController.text.trim().toUpperCase();
    nums = int.tryParse(doorNumberController.text);
    hobbies = interestsController.text;
    job = jobController.text;

    if (nums == null || nums <= 0) {
      setState(() {
        errorMessage = "Please enter a valid Door Number.";
      });

      return;
    }
    if (block.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter a valid Block.";
      });

      return;
    }
    if (selectedStatus == null) {
      setState(() {
        errorMessage = "Please enter a valid Response.";
      });

      return;
    }
    setState(() {
      errorMessage = null;
    });
    final Apartment apartment = Apartment(
      block: block,
      doorNumber: nums,
      status: selectedStatus!,
      interests: hobbies,
      job: job,
    );
    Navigator.pop(context, apartment);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.initialApartment != null
              ? Text("Edit Apartment")
              : Text("Add Apartment"),
          SizedBox(height: 16),
          Row(
            children: [
              ApartmentTextField(
                controller: blockController,
                label: "Block",
                readOnly: widget.initialApartment != null,
              ),

              SizedBox(width: 12),

              ApartmentTextField(
                label: "Door Number",
                keyboardType: TextInputType.number,
                controller: doorNumberController,
                readOnly: widget.initialApartment != null,
              ),
            ],
          ),

          SizedBox(
            height: 16,
          ),

          Row(
            children: [
              ApartmentTextField(
                label: "Interests",
                controller: interestsController,
              ),

              SizedBox(width: 12),

              ApartmentTextField(
                label: "Job",
                controller: jobController,
              ),
            ],
          ),

          SurveyResponse(
            onStatusChanged: (newStatus) {
              setState(() {
                selectedStatus = newStatus;
              });
            },
            selectedStatus: selectedStatus,
          ),

          SizedBox(height: 12),

          if (errorMessage != null)
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.red),
            ),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _saveApartment,
              child: widget.initialApartment != null
                  ? Text("Update Apartment")
                  : Text("Save Apartment"),
            ),
          ),
        ],
      ),
    );
  }
}
