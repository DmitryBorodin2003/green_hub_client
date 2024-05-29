import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:green_hub_client/models/achievement.dart';

class IconSelectionDialog extends StatefulWidget {
  final List<String> availableIcons = ['Волонтёр', 'Защитник животных', 'Активный пользователь', 'Веган', 'Велосипедист'];
  final List<Achievement> availableAchievements;
  final List<Achievement> selectedAchievements;

  IconSelectionDialog({required this.selectedAchievements, required this.availableAchievements});

  @override
  _IconSelectionDialogState createState() => _IconSelectionDialogState();
}

class _IconSelectionDialogState extends State<IconSelectionDialog> {
  late List<String> _selectedIcons;

  @override
  void initState() {
    super.initState();
    decodeAchievementImages();
    _selectedIcons = widget.selectedAchievements.map((achievement) => achievement.name).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFFDCFED7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(
        'Выберите значки',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: Colors.grey,
          ),
          ...widget.availableAchievements.map((achievement) {
            bool isSelected = _selectedIcons.contains(achievement.name);
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Row(
                children: [
                  Image.memory(
                    achievement.decodedImage!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      achievement.name,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              value: isSelected,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected ?? false) {
                    _selectedIcons.add(achievement.name);
                  } else {
                    _selectedIcons.remove(achievement.name);
                  }
                });
              },
            );
          }).toList() ?? [],
        ],
      ),
      actions: <Widget>[
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedIcons);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
            ),
            child: Text('ОК'),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
  void decodeAchievementImages() {
    for (var achievement in widget.availableAchievements) {
      achievement.decodedImage = base64.decode(achievement.image);
    }
  }
}
