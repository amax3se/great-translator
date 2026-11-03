import 'package:flutter/material.dart';
import 'services/speech_analyze.dart';
import 'services/translate.dart';
import 'services/tts.dart';

void main() { // initializing the app (just running it)
  runApp(const TranslatorApp());
}

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Great translator',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget { 
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> { // main logic
  final SpeechService _speechService = SpeechService();
  final TranslateService _translateService = TranslateService();
  final TtsService _ttsService = TtsService();

  String _recognizedText = ''; // _ = private (like in C#)
  String _translatedText = '';
  bool _isListening = false;
  bool _isLoading = false;

  String _fromLang = 'en';
  String _toLang = 'ru';

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _speechService.initialize();
    await _ttsService.initialize();
  }

  String _getLocale(String langCode) { // right lang name
    switch (langCode) {
      case 'ru': return 'ru_RU';
      case 'en': return 'en_US';
      case 'es': return 'es_ES';
      case 'fr': return 'fr_FR';
      case 'de': return 'de_DE';
      case 'zh': return 'zh_CN';
      default: return 'en_US';
    }
  }

  void _toggleListening() { // micro button
    if (_isListening) {
      _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() { // нужен чтобы менялся и ui и переменная
        _isListening = true;
        _recognizedText = '';
        _translatedText = '';
      });

      _speechService.startListening(
        localeId: _getLocale(_fromLang),
        onResult: (text) {
          setState(() {
            _recognizedText = text;
          });
          if (text.trim().isNotEmpty) {
            _translate(text);
          }
        },
      );
    }
  }

  Future<void> _translate(String text) async { // translating
    if (text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final result = await _translateService.translate(
      text: text,
      from: _fromLang,
      to: _toLang,
    );

    setState(() {
      _translatedText = result;
      _isLoading = false;
    });
  }

  void _speakTranslation() {
    if (_translatedText.isNotEmpty) {
      _ttsService.speak(_translatedText);
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _fromLang;
      _fromLang = _toLang;
      _toLang = temp;
      _recognizedText = '';
      _translatedText = '';
    });
  }

  @override
  Widget build(BuildContext context) { // UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Great translator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _languageDropdown(_fromLang, (val) {
                  setState(() => _fromLang = val!);
                }),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapLanguages,
                ),
                _languageDropdown(_toLang, (val) {
                  setState(() => _toLang = val!);
                }),
              ],
            ),
            const SizedBox(height: 24),
            _textCard(
              title: 'Original',
              text: _recognizedText.isEmpty
                  ? 'Press on the micro'
                  : _recognizedText,
            ),
            const SizedBox(height: 16),
            _textCard(
              title: 'Translate',
              text: _isLoading
                  ? 'Translating...'
                  : (_translatedText.isEmpty ? '—' : _translatedText),
              action: _translatedText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: _speakTranslation,
                    )
                  : null,
            ),
            const Spacer(),
            FloatingActionButton.large(
              onPressed: _toggleListening,
              backgroundColor:
                  _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
              child: Icon(_isListening ? Icons.stop : Icons.mic, size: 36),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _textCard({
    required String title,
    required String text,
    Widget? action,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (action != null) action,
              ],
            ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _languageDropdown(String value, void Function(String?) onChanged) {
    return DropdownButton<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'ru', child: Text('Русский')),
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'es', child: Text('Español')),
        DropdownMenuItem(value: 'fr', child: Text('Français')),
        DropdownMenuItem(value: 'de', child: Text('Deutsch')),
        DropdownMenuItem(value: 'zh', child: Text('中文')),
      ],
      onChanged: onChanged,
    );
  }
}