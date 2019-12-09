library aug_widgets;

import 'dart:async';

import 'package:aug_widgets/utils.dart';
import 'package:flutter/material.dart';

class SuggestionTextFormField extends StatefulWidget {
  final SuggestionTextController controller;
  final List<String> suggestionList;
  final String labelText;
  final String hintText;
  final bool multipleValue;
  final FormFieldValidator<String> validator;

  SuggestionTextFormField(
      {this.controller,
      this.suggestionList,
      this.labelText,
      this.hintText,
      this.multipleValue = false,
      this.validator});

  @override
  State<StatefulWidget> createState() {
    return _SuggestionTextFormFieldState();
  }
}

class _SuggestionTextFormFieldState extends State<SuggestionTextFormField> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  TextEditingController _textEditingController;
  Timer _timer;
  List suggestionList = [];
  List<String> _items = [];

  SuggestionTextController _controller;

  SuggestionTextController get _effectiveController =>
      widget.controller ?? _controller;

  @override
  void initState() {
    super.initState();
    _items = widget.controller?.value ?? [];

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry);
      } else {
        _removeOverlayEntry();
      }
    });

    if (widget.controller == null) {
      _controller = SuggestionTextController();
    }

    _textEditingController = TextEditingController();
    _textEditingController.addListener(_handleTextInsideChanged);
    if (!widget.multipleValue &&
        !Utils.isNullOrEmpty(_effectiveController.text)) {
      _textEditingController.text = _effectiveController.text;
    }
  }

  @override
  void didUpdateWidget(SuggestionTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null)
      _controller =
          SuggestionTextController.fromValue(oldWidget.controller.value);
    else if (widget.controller != null && oldWidget.controller == null)
      _controller = null;
  }

  void _handleTextInsideChanged() {
    final String value = _textEditingController.text;

    if (_effectiveController.value != null &&
        !_effectiveController.value.contains(value)) {
      _effectiveController.setFirst(value);
    } else {
      _effectiveController.add(value);
    }

    if (Utils.isNullOrEmpty(value)) {
      if (_timer != null) {
        _timer.cancel();
      }

      _removeOverlayEntry();
    } else {
      if (_timer != null) {
        _timer.cancel();
      }

      _timer = Timer(const Duration(milliseconds: 100), () {
        List<String> temp = [];
        if (widget.suggestionList != null) {
          widget.suggestionList.forEach((val) {
            if (val.toLowerCase().indexOf(value) > -1) {
              temp.add(val);
            }
          });

          setState(() {
            suggestionList = temp;
          });

          _removeOverlayEntry();
          if (suggestionList.isNotEmpty) {
            _overlayEntry = _createOverlayEntry();
            Overlay.of(context).insert(_overlayEntry);
          }
        }
      });
    }
  }

  void _setControllerValue(String value) {
    if (_effectiveController.value == null) _effectiveController.value = [];
    if (_effectiveController.value.isEmpty) _effectiveController.value.add('');
    if (_effectiveController.value[0] == value)
      _effectiveController.value[0] = '';
    _effectiveController.add(value);
    setState(() {
      _items = _effectiveController.value ?? [];
    });
  }

  void _removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    //suggestionList = List?.from(widget.suggestionList) ?? [];

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 1.0,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: suggestionList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestionList[index]),
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _textEditingController.text = suggestionList[index];
                    _removeOverlayEntry();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _textEditingController,
            focusNode: _focusNode,
            validator: widget.validator,
            decoration: InputDecoration(
              labelText: widget.labelText ?? '',
              hintText: widget.hintText ?? '',
              suffixIcon: widget.multipleValue
                  ? IconButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _setControllerValue(_textEditingController.text);
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _textEditingController.clear());
                      },
                      icon: Icon(Icons.add),
                    )
                  : SizedBox(),
            ),
          ),
          (widget.multipleValue && _items.isNotEmpty && _items.length > 1)
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        style: BorderStyle.solid,
                        width: 1.0,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: _buildItems(),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    List<Widget> rs = [];
    var index = 0;
    _items.forEach((val) {
      if (index != 0) {
        // 0 is value of text field
        rs.add(Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: SuggestionItem(
            text: val,
            onDeleteTap: () {
              _effectiveController.remove(val);
              setState(() {
                _items = _effectiveController?.value ?? [];
              });
            },
          ),
        ));
        rs.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
          ),
        );
      }

      index++;
    });

    return rs;
  }

  @override
  void dispose() {
    _textEditingController?.removeListener(_handleTextInsideChanged);
    super.dispose();
  }
}

class SuggestionTextController extends ValueNotifier<List<String>> {
  SuggestionTextController({List<String> value}) : super(value ?? []);

  SuggestionTextController.fromValue(List<String> value) : super(value ?? []);

  String get text {
    var rs = value?.join(',');
    if (rs.startsWith(',')) rs = rs.substring(1);

    return rs;
  }

  set text(String valueText) {
    if (!Utils.isNullOrEmpty(valueText)) {
      value = [''];
      value.addAll(valueText.split(','));
    } else {
      value = [];
    }
    notifyListeners();
  }

  void add(String val) {
    if (value == null) {
      value = [];
    }
    if (value.isEmpty) value.add(val);

    if (val.isNotEmpty && !value.contains(val)) {
      value.add(val);
      notifyListeners();
    }
  }

  void setFirst(String val) {
    if (value != null && value.isNotEmpty && value.elementAt(0) != null) {
      if (value.indexOf(val) == -1) {
        value[0] = val;
        notifyListeners();
      } else {
        value[0] = '';
        notifyListeners();
      }
    } else {
      if (value == null) {
        value = [];
      }
      value.insert(0, val);
      notifyListeners();
    }
  }

  void remove(String val) {
    if (value == null) return;
    if (val.isEmpty) return;

    value.remove(val);
    notifyListeners();
  }

  void clear() {
    value = [];
  }
}

class SuggestionItem extends StatefulWidget {
  final String text;
  final VoidCallback onDeleteTap;

  SuggestionItem({this.text, this.onDeleteTap});

  @override
  State<StatefulWidget> createState() {
    return _SuggestionItemState();
  }
}

class _SuggestionItemState extends State<SuggestionItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 5.0,
        top: 3.0,
        bottom: 3.0,
      ),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
      ),
      child: SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.text,
              style: TextStyle(fontSize: 12.0),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0),
            ),
            GestureDetector(
              onTap: () {
                if (widget.onDeleteTap != null) {
                  Function.apply(widget.onDeleteTap, []);
                }
              },
              child: Icon(
                Icons.clear,
                size: 20.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
