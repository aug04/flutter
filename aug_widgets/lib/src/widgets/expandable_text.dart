import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

class ExpandableText extends StatefulWidget {
  final String data;
  final int maxLines;
  final TextOverflow overflow;
  final TextStyle style;
  final String showMoreText;
  final String showLessText;
  final bool allowShowLess;

  const ExpandableText(
    this.data, {
    this.maxLines = 3,
    this.overflow = TextOverflow.fade,
    this.style = const TextStyle(),
    this.showMoreText,
    this.showLessText,
    this.allowShowLess = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _ExpandableTextState();
  }
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: _isExpanded ? double.infinity : 90,
              maxWidth: double.infinity,
            ),
            child: Text(
              widget.data,
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow: widget.overflow,
              style: widget.style,
            ),
          ),
          widget.allowShowLess
              ? GestureDetector(
                  onTap: _handleOnTap,
                  child: Text(
                    _isExpanded
                        ? widget.showLessText ?? 'show less'
                        : widget.showMoreText ?? '...',
                    style: widget.style.merge(
                      TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                )
              : (!_isExpanded
                  ? GestureDetector(
                      onTap: _handleOnTap,
                      child: Text(
                        widget.showMoreText ?? '...',
                        style: widget.style.merge(
                          TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    )),
        ],
      ),
    );
  }

  void _handleOnTap() {
    setState(() => _isExpanded = !_isExpanded);
  }
}
