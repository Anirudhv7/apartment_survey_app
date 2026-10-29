import 'package:flutter/material.dart';

class SurveyResponse extends StatelessWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  const SurveyResponse({
    super.key,
    this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildCheckBox("Interested", "interested"),
        buildCheckBox("Not Interested", "not_interested"),
        buildCheckBox("No Answer", "no_answer"),
      ],
    );
  }

  Widget buildCheckBox(
    String label,
    String status,
  ) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(label),
      value: selectedStatus == status,
      onChanged: (bool? value) {
        if (value == true) {
          return onStatusChanged(status);
        } else {
          onStatusChanged(null);
        }
      },
    );
  }
}
