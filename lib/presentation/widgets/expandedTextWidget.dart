
import 'package:flutter/material.dart';

class ExpandedTextWidget extends StatefulWidget {
  final String text;
  const ExpandedTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  State<ExpandedTextWidget> createState() => _ExpandedTextWidgetState();
}

class _ExpandedTextWidgetState extends State<ExpandedTextWidget> {
  late String firstHalf;
  late String secondHalf;
  
  @override
  void initState() {
    super.initState();
    if(widget.text.length > 30 ){
      firstHalf = widget.text.substring(0, 30);
      secondHalf = widget.text.substring(31, widget.text.length);
    }else{
      firstHalf = widget.text;
      secondHalf = "";
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        widget.text
      ),
    );
  }
}
