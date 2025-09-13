import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart'; // External package for expression evaluationer

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';
  bool _hasError = false;

  final List<String> _buttons = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    'C', '0', '=', '+',
    '%', 'x²' // <-- Added modulo and square buttons
  ];

  void _onButtonPressed(String value) {
    setState(() {
      _hasError = false;
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '=') {
        if (_expression.isEmpty) return;
        try {
          final exp = Expression.parse(_expression);
          final evaluator = const ExpressionEvaluator();
          final evalResult = evaluator.eval(exp, {});
          _result = evalResult.toString();
          _expression = '$_expression = $_result';
        } catch (e) {
          _result = 'Error';
          _hasError = true;
        }
      } else if (value == 'x²') {
        // Square the current number/expression
        if (_expression.isEmpty || _expression.contains('=')) return;
        try {
          final exp = Expression.parse(_expression);
          final evaluator = const ExpressionEvaluator();
          final evalResult = evaluator.eval(exp, {});
          final squared = (evalResult is num) ? evalResult * evalResult : null;
          if (squared != null) {
            _expression = '($_expression)²';
            _result = squared.toString();
            _expression = '$_expression = $_result';
          }
        } catch (e) {
          _result = 'Error';
          _hasError = true;
        }
      } else {
        if (_expression.contains('='))
          _expression = '';
        if (value == '%') {
          _expression += '%';
        } else {
          _expression += value;
        }
      }
    });
  }

  Widget _buildButton(String value) {
    Color bgColor;
    if (value == 'C') {
      bgColor = Colors.red.shade300;
    } else if ('/*-+=%'.contains(value) || value == 'x²') {
      bgColor = Colors.blue.shade300;
    } else {
      bgColor = Colors.grey.shade200;
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontSize: 24),
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _onButtonPressed(value),
          child: Text(value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator - Badhan Hasan'), 
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _expression.isEmpty ? '0' : _expression,
                style: TextStyle(
                  fontSize: 32,
                  color: _hasError ? Colors.redAccent : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < _buttons.length; i += 4)
                    Row(
                      children: [
                        if (i < _buttons.length) _buildButton(_buttons[i]),
                        if (i + 1 < _buttons.length) _buildButton(_buttons[i + 1]),
                        if (i + 2 < _buttons.length) _buildButton(_buttons[i + 2]),
                        if (i + 3 < _buttons.length) _buildButton(_buttons[i + 3]),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
