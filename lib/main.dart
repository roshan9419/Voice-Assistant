import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreenView(),
    );
  }
}

class SpeechScreenView extends StatefulWidget {
  @override
  _SpeechScreenViewState createState() => _SpeechScreenViewState();
}

class _SpeechScreenViewState extends State<SpeechScreenView> {
  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
        onTap: () => print('flutter'),
        textStyle:
            const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
    'kotlin': HighlightedWord(
        onTap: () => print('kotlin'),
        textStyle:
            const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
    'java': HighlightedWord(
        onTap: () => print('java'),
        textStyle:
            const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
  };

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking";
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        glowColor: Theme.of(context).primaryColor,
        animate: _isListening,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        child: FloatingActionButton(
          onPressed: () => _listen(),
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: TextHighlight(
            text: _text,
            words: _highlights,
            textStyle: const TextStyle(
                fontSize: 32.0,
                color: Colors.black,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'));

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() {
                  _text = val.recognizedWords;
                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _confidence = val.confidence;
                  }
                }));

      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
