import 'dart:math';
import 'package:flutter/material.dart';

class SmartFolder extends StatefulWidget {
  final Widget child; //子组件 @required
  final List<Widget> children; //折叠内容
  final Widget tile; //尾部折叠指示组件 - 默认[]
  final int duration; //折叠时长 - 默认200 ms
  final double tileOffsetRight; //指示组件右边距 - 默认10
  final Color tileColor; //指示组件颜色 - 默认为黑色
  final Curve foldCurve; //动画曲线 - 默认Curves.easeInToLinear
  final ValueChanged<bool> onExpansionChanged; //折叠回调
  final bool initiallyExpanded; // 是否一开始展开
  final String groupName;


  SmartFolder(
      {Key key,
      @required this.child,
      this.initiallyExpanded = false,
      this.tile,
      this.foldCurve = Curves.easeInToLinear,
      this.tileOffsetRight = 10.0,
      this.tileColor = Colors.black,
      this.duration = 200,
      this.onExpansionChanged,
      this.children = const <Widget>[],
      this.groupName})
      : assert(tileColor != null),
        super(key: key);

  @override
  _SmartFolderState createState() => _SmartFolderState();
}

class _SmartFolderState extends State<SmartFolder>
    with SingleTickerProviderStateMixin {
  static Map<String,Map<Key,bool>> groupState={};
  var _crossFadeState = CrossFadeState.showFirst;

  bool get isFirst => _crossFadeState == CrossFadeState.showFirst;

  AnimationController _controller;
  Animation _rotate;
  double _rad = 0;
  bool _rotated = false;

  @override
  void initState() {
    super.initState();
    if(widget.groupName!=null && widget.groupName.isNotEmpty){
      if(!groupState.containsKey(widget.groupName)) {
        Map<Key, bool>entry = Map();
        entry[widget.key] = widget.initiallyExpanded;
        groupState[widget.groupName] = entry;
      }else{
        groupState[widget.groupName].putIfAbsent(widget.key, ()=>widget.initiallyExpanded);
      }
    }
    _controller = AnimationController(
        duration: Duration(milliseconds: widget.duration), vsync: this)
      ..addListener(_listenAnim)
      ..addStatusListener(_listenStatus);
    if (widget.initiallyExpanded) {
      // _crossFadeState = CrossFadeState.showSecond;
      Future.delayed(Duration(milliseconds: 300),_togglePanel);
    }
    _rotate = CurvedAnimation(parent: _controller, curve: widget.foldCurve);
  }

  _listenAnim() => setState(
      () => _rad = (_rotated ? (1 - _rotate.value) : _rotate.value) * pi / 2);

  _listenStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _rotated = !_rotated;
    }
  }

  @override
  Widget build(BuildContext context) {
    var tile = widget.tile ??
        Icon(
          Icons.keyboard_arrow_right,
          color: widget.tileColor,
        );

    return Column(
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(onTap: _togglePanel, child: widget.child),
            Positioned(
                right: widget.tileOffsetRight,
                child: Transform(
                  transform: Matrix4.rotationZ(_rad),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: _togglePanel,
                    child: tile,
                  ),
                ))
          ],
        ),
        _buildPanel()
      ],
    );
  }

  void _togglePanel() {
    _controller.reset();
    _controller.forward();
    if (widget.onExpansionChanged != null) widget.onExpansionChanged(isFirst);
    setState(() {
      _crossFadeState =
          !isFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond;
    });
  }

  Widget _buildPanel() => AnimatedCrossFade(
        sizeCurve: widget.foldCurve,
        firstChild: Container(),
        secondChild:
            Column(mainAxisSize: MainAxisSize.min, children: widget.children),
        duration: Duration(milliseconds: widget.duration),
        crossFadeState: _crossFadeState,
      );
}
