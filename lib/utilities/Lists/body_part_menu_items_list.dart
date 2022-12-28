import 'package:flutter/material.dart';

List<DropdownMenuItem<String>> get dropdownItems{
  List<DropdownMenuItem<String>> menuItems = [
    const DropdownMenuItem(value: "Chest", child: Text("Chest")),
    const DropdownMenuItem(value: "Arms", child: Text("Arms")),
    const DropdownMenuItem(value: "Back", child: Text("Back")),
    const DropdownMenuItem(value: "Shoulders", child: Text("Shoulders")),
    const DropdownMenuItem(value: "Legs", child: Text("Legs")),
    const DropdownMenuItem(value: "Core", child: Text("Core")),
  ];
  return menuItems;
}