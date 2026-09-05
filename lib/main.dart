import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'payment_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.black),
      ),
      home: const MyHomePage(title: 'My fancy Laboratorul 1 '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isButtonEnabled = false;
  int? _height;
  double? _weight;
  double _imc = 0;
  String _status = "";
  final Color _backgroundColor = Colors.black;
  final Color _textColor = Colors.orangeAccent;

  void _setButtonActivityStatus() {
    if (_height != null && _weight != null) {
      if (!_isButtonEnabled) {
        setState(() => _isButtonEnabled = true);
      }
    } else {
      if (_isButtonEnabled) {
        setState(() => _isButtonEnabled = false);
      }
    }
  }

  Future<void> _recalculate(BuildContext context) async {
    // Gate the result behind a simulated \$0.99 payment. The response is only
    // revealed once the payment dialog reports success and then closes.
    final bool paid = await PaymentDialog.show(
      context,
      textColor: _textColor,
      backgroundColor: _backgroundColor,
    );
    if (!paid || !mounted) return;

    double heightInM = _height! / 100;
    double squaredHeight = heightInM * heightInM;
    _imc = _weight! / squaredHeight;
    var status = _getStatus();
    if (status != _status) {
      _setStatus(status);
    }
  }

  String _getStatus() {
    if (_imc < 18.5) {
      return "Underweight";
    } else if (_imc <= 24.9) {
      return "Normal weight\n|| OR ||\nOm uspesnai";
    } else if (_imc <= 29.9) {
      return "Overweight";
    } else {
      return "Obesity";
    }
  }

  void _setStatus(String newStatus) => setState(() => _status = newStatus);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: _backgroundColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(style: TextStyle(color: _textColor), widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(40.0, 0, 40, 5),
              child: TextField(
                onChanged: (value) => {
                  if (_height == "")
                    {_height = null}
                  else
                    {_height = int.parse(value)},
                  _setButtonActivityStatus(),
                },
                keyboardType: TextInputType.number,
                style: TextStyle(color: _textColor),
                decoration: InputDecoration(
                  labelText: 'Enter your height(in cm)',
                  labelStyle: TextStyle(color: _textColor),
                  hintText: '180',
                  hintStyle: TextStyle(color: _textColor),
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(40.0, 5, 40, 10),
              child: TextField(
                onChanged: (value) => {
                  if (value == "")
                    {_weight = null}
                  else
                    {_weight = double.parse(value)},
                  _setButtonActivityStatus(),
                },
                keyboardType: TextInputType.number,
                style: TextStyle(color: _textColor),
                decoration: InputDecoration(
                  labelText: 'Enter your weight(in kg)',
                  labelStyle: TextStyle(color: _textColor),
                  hintText: '190',
                  hintStyle: TextStyle(color: _textColor),
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: Text('You are:', style: TextStyle(color: _textColor)),
            ),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: _textColor),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () => _recalculate(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _textColor,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: _textColor.withValues(alpha: 0.4),
                  disabledForegroundColor: Colors.black,
                  elevation: 5,
                  fixedSize: Size(200, 45),
                ),
                child: const Text("press me :)"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
