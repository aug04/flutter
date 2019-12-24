import 'package:aug_widgets/aug_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AUG Widgets Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AugWidgetsExample(),
    );
  }
}

class AugWidgetsExample extends StatelessWidget {
  final List<String> _suggestionList = [
    'Flutter',
    'Aug Widgets',
    'Dart',
    'Amazing',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AUG Widgets Demo'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(
          top: 20.0,
          left: 20.0,
          right: 20.0,
        ),
        child: ListView(
          children: <Widget>[
            ExpandableText(
              '''Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.''',
              allowShowLess: true,
              showLessText: 'show less',
            ),
            SuggestionTextFormField(
              labelText: 'Enter your keyword',
              hintText: 'Enter your keyword...',
              suggestionList: _suggestionList,
            ),
          ],
        ),
      ),
    );
  }
}
