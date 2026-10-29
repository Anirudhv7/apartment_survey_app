import 'package:flutter/material.dart';

class DropDownBlocks extends StatelessWidget {
  final String selectedBlock;
  final ValueChanged<String> onBlockChanged;

  const DropDownBlocks({
    super.key,
    required this.selectedBlock,
    required this.onBlockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      onChanged: (newBlockValue) {
        if (newBlockValue != null) {
          onBlockChanged(newBlockValue);
        }
      },
      value: selectedBlock,
      items: [
        DropdownMenuItem<String>(
          value: "all",
          child: Text("All Blocks"),
        ),
        DropdownMenuItem<String>(
          value: "A",
          child: Text("Block A"),
        ),
        DropdownMenuItem<String>(
          value: "B",
          child: Text("Block B"),
        ),
        DropdownMenuItem<String>(
          value: "C",
          child: Text("Block C"),
        ),
        DropdownMenuItem<String>(
          value: "D",
          child: Text("Block D"),
        ),
        DropdownMenuItem<String>(
          value: "E",
          child: Text("Block E"),
        ),
      ],
    );
  }
}
