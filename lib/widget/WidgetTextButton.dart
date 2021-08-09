import 'package:flutter/material.dart';

class WidgetTextButton extends StatefulWidget {
  final Widget widget;
  final Text label;

  const WidgetTextButton({
    Key? key,
    required this.widget,
    required this.label,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WidgetTextButtonState();
}

///
/// The State of IconTextButton
/// 状态类
///
class _WidgetTextButtonState extends State<WidgetTextButton> {
  @override
  Widget build(BuildContext context) {
    var wid = Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[widget.widget, widget.label],
    );
    return wid;
  }
}
