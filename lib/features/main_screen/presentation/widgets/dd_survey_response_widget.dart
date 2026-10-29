import 'package:flutter/material.dart';

class DropDownSurveyResponse extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  const DropDownSurveyResponse({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedFilter,
      onChanged: (newvalue) {
        if (newvalue != null) {
          onFilterChanged(newvalue);
        }
      },
      items: [
        DropdownMenuItem<String>(
          value: "all",
          child: Text("All Apartments"),
        ),
        DropdownMenuItem<String>(
          value: "interested",
          child: Text("Interested"),
        ),
        DropdownMenuItem<String>(
          value: "not_interested",
          child: Text("Not Interested"),
        ),
        DropdownMenuItem<String>(
          value: "no_answer",
          child: Text("No Answer"),
        ),
      ],
    );
  }
}
