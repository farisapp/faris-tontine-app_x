import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatefulWidget {

  String? message;
  ProgressDialog({super.key, this.message});

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade800,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(width: 6.0,),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(width: 26.0,),
              Text(
                  widget.message!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
