import 'package:flutter/material.dart';

class ErrorAlertDialog extends StatelessWidget {
  final String errorContent;
  const ErrorAlertDialog({required this.errorContent, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Uwaga!"),
        content: Text(errorContent),
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
