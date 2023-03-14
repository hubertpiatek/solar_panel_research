import 'package:flutter/material.dart';

class WaitingDialog extends StatelessWidget {
  final String dialogContent;
  const WaitingDialog({required this.dialogContent, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Container(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Uwaga!",
              style: TextStyle(fontSize: 21, color: Colors.black87),
            )),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.25,
          margin: const EdgeInsets.all(6.0),
          child: Column(
            children: [
              Text(
                dialogContent,
                style: const TextStyle(fontSize: 17, color: Colors.black54),
              ),
              const SizedBox(
                height: 50,
              ),
              const SizedBox(
                  width: 50, height: 50, child: CircularProgressIndicator())
            ],
          ),
        ),
        actions: const []);
  }
}
