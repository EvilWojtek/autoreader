import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';

enum LuminanceMode { negative, bipolar, positive }

const millisecondsPerMinute = 60000;

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  TextEditingController wordsController = TextEditingController.fromValue(const TextEditingValue(
    text: 'So I made this cool app that makes reading more engaging or something idk. I was just bored, hope you enjoy playing with it :D',
  ));
  PickerFont? _selectedFont;

  bool showSettings = false;
  bool showTextEditor = false;
  bool showHelp = false;

  double wordsPerMinute = 250;
  String fontFamily = 'Roboto';
  double fontSize = 32;
  bool isBackgroundStatic = false;
  double backgroundColorIntensity = 0.5;
  Color staticBackgroundColor = Colors.white;
  Color textColor = Colors.black;

  bool isRunning = false;
  int i = 0;
  Timer timer = Timer(Duration.zero, () {});

  List<String> words =
      'So I made this cool app that makes reading more engaging or something idk. I was just bored, hope you enjoy playing with it :D'.split(' ');

  void _toggleRunning() async {
    if (i >= words.length - 1) {
      setState(() {
        i = 0;
      });
      await Future.delayed(Duration(
        milliseconds: ((1 / wordsPerMinute) * millisecondsPerMinute).toInt(),
      ));
    }
    if (isRunning) {
      isRunning = false;
    } else {
      isRunning = true;
      _nextWord();
    }
  }

  void _nextWord() {
    if (i >= words.length - 1 || !isRunning) {
      isRunning = false;
      timer.cancel();
      return;
    }
    setState(() {
      i++;
    });
    timer = Timer(
      Duration(
        milliseconds: ((1 / wordsPerMinute) * millisecondsPerMinute).toInt(),
      ),
      () => _nextWord(),
    );
  }

  void _setText(String text) {
    i = 0;
    words = text.trim().replaceAll('\n', ' ').split(' ').where((element) => element != '').toList();
    setState(() {});
  }

  int _colorHash(String value) {
    int hash = 0;
    for (final code in value.runes) {
      hash = code + ((hash << 5) - hash);
    }
    return hash;
  }

  Color _invertColor(Color color) {
    final r = 255 - color.red;
    final g = 255 - color.green;
    final b = 255 - color.blue;

    return Color.fromARGB((color.opacity * 255).round(), r, g, b);
  }

  Color _stringToColor(String value, {LuminanceMode luminanceMode = LuminanceMode.bipolar}) {
    String c = (_colorHash(value) & 0x00FFFFFF).toRadixString(16).toUpperCase();
    String hex = "FF00000".substring(0, 8 - c.length) + c;
    final color = Color(int.parse(hex, radix: 16));
    switch (luminanceMode) {
      case LuminanceMode.positive:
        return color.computeLuminance() > 0.5 ? color : _invertColor(color);
      case LuminanceMode.negative:
        return color.computeLuminance() < 0.5 ? color : _invertColor(color);
      case LuminanceMode.bipolar:
        return color;
    }
  }
  //

  @override
  Widget build(BuildContext context) {
    final color = isBackgroundStatic
        ? staticBackgroundColor
        : Color.lerp(
            _stringToColor(words.isEmpty ? 'lmao' : words[i],
                luminanceMode: textColor.computeLuminance() < 0.5 ? LuminanceMode.positive : LuminanceMode.negative),
            Colors.white,
            1 - backgroundColorIntensity,
          )!;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _toggleRunning(),
                  child: Container(
                    color: color,
                    child: Center(
                      child: Text(
                        words.isEmpty ? 'Add Some Text' : words[i],
                        style: TextStyle(
                          color: textColor,
                          fontSize: fontSize,
                        ).merge(_selectedFont?.toTextStyle()),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () => setState(
                          () => showSettings = !showSettings,
                        ),
                        icon: const Icon(Icons.settings),
                      ),
                      IconButton(
                        onPressed: () => setState(
                          () => showTextEditor = !showTextEditor,
                        ),
                        icon: const Icon(Icons.text_fields),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          i = 0;
                        }),
                        icon: const Icon(Icons.restart_alt),
                      ),
                      IconButton(
                        onPressed: () => setState(
                          () => showHelp = !showHelp,
                        ),
                        icon: const Icon(Icons.help),
                      ),
                    ],
                  ),
                ),
                if (showTextEditor)
                  Positioned(
                    top: 0,
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                                  child: Text(
                                    'Text',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                                  child: IconButton(
                                    onPressed: () => setState(
                                      () => showTextEditor = false,
                                    ),
                                    icon: const Icon(
                                      Icons.close,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(135, 220, 220, 220),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: TextField(
                                      controller: wordsController,
                                      decoration: null,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      onChanged: (value) => _setText(value),
                                      maxLines: null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (showHelp)
                  Center(
                    child: Container(
                      height: 160,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: Text(
                                  'Help',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                child: IconButton(
                                  onPressed: () => setState(
                                    () => showHelp = false,
                                  ),
                                  icon: const Icon(
                                    Icons.close,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text('To start playing click anywhere, then click again to pause \nHave fun :D'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showSettings)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        Text('Words Per Minute (${wordsPerMinute.toStringAsFixed(0)})'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('50'),
                            Slider(
                              min: 50,
                              max: 1200,
                              value: wordsPerMinute,
                              onChanged: (value) => setState(() {
                                wordsPerMinute = value;
                              }),
                              label: 'Words per minute',
                            ),
                            const Text('2000'),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Font Size (${fontSize.toStringAsFixed(1)})'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('5'),
                            Slider(
                              min: 5,
                              max: 100,
                              value: fontSize,
                              onChanged: (value) => setState(() {
                                fontSize = value;
                              }),
                              label: 'Font Size',
                            ),
                            const Text('100'),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Background Color Intensity (${backgroundColorIntensity.toStringAsFixed(2)})'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('0.0'),
                            Slider(
                              min: 0.0,
                              max: 1.0,
                              value: backgroundColorIntensity,
                              onChanged: (value) => setState(() {
                                backgroundColorIntensity = value;
                              }),
                              label: 'Background Color Intensity',
                            ),
                            const Text('1.0'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        child: const Text('Pick a font'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FontPicker(
                                onFontChanged: (PickerFont font) {
                                  setState(() {
                                    _selectedFont = font;
                                  });
                                },
                              ),
                            ),
                          );
                        }),
                    const SizedBox(height: 16),
                    const Center(child: Text('Text Color')),
                    const SizedBox(height: 8),
                    ColorPicker(
                      pickerColor: textColor,
                      onColorChanged: (value) => setState(() {
                        textColor = value;
                      }),
                      pickerAreaBorderRadius: BorderRadius.circular(4),
                      enableAlpha: false,
                      portraitOnly: true,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isBackgroundStatic,
                          onChanged: (value) => setState(() {
                            isBackgroundStatic = value!;
                          }),
                        ),
                        const Text('Static Background Color'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isBackgroundStatic) const Center(child: Text('Background Color')),
                    const SizedBox(height: 8),
                    if (isBackgroundStatic)
                      ColorPicker(
                        pickerColor: staticBackgroundColor,
                        onColorChanged: (value) => setState(() {
                          staticBackgroundColor = value;
                        }),
                        pickerAreaBorderRadius: BorderRadius.circular(4),
                        enableAlpha: false,
                        portraitOnly: true,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
