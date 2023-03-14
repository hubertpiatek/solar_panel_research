import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String infoContent;
  final String titleContent;
  const InfoDialog(
      {required this.titleContent, required this.infoContent, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(titleContent),
        content: Text(infoContent),
        actions: [
          TextButton(
            child: const Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]);
  }
}
