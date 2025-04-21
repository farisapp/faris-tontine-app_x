import 'package:flutter/material.dart';

class CustomerLoader extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        )
    );
  }
}