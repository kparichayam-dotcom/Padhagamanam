import 'package:flutter/material.dart';

void main() {
  runApp(const PadagamanamApp());
}

class PadagamanamApp extends StatelessWidget {
  const PadagamanamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'పదగమనం',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CrosswordEditor(),
    );
  }
}

class CrosswordEditor extends StatefulWidget {
  const CrosswordEditor({super.key});

  @override
  State<CrosswordEditor> createState() => _CrosswordEditorState();
}

class _CrosswordEditorState extends State<CrosswordEditor> {
  static const int size = 15;

  late List<List<bool>> blackCells;
  late List<List<String>> letters;

  final Map<String, String> clues = {};
  final Map<String, String> answers = {};

  @override
  void initState() {
    super.initState();
    blackCells = List.generate(
      size,
      (_) => List.generate(size, (_) => false),
    );
    letters = List.generate(
      size,
      (_) => List.generate(size, (_) => ''),
    );
  }

  void toggleCell(int row, int col) {
    setState(() {
      blackCells[row][col] = !blackCells[row][col];
      if (blackCells[row][col]) {
        letters[row][col] = '';
      }
    });
  }

  Future<void> editLetter(int row, int col) async {
    if (blackCells[row][col]) return;

    final controller = TextEditingController(text: letters[row][col]);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('తెలుగు అక్షరం'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 4,
          decoration: const InputDecoration(
            hintText: 'అక్షరం నమోదు చేయండి',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('రద్దు'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('సేవ్'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        letters[row][col] = result;
      });
    }
  }

  Future<void> addClue() async {
    final numberController = TextEditingController();
    final clueController = TextEditingController();
    final answerController = TextEditingController();
    String direction = 'Across';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ప్రశ్న జోడించండి'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ప్రశ్న నంబర్'),
                ),
                DropdownButtonFormField<String>(
                  value: direction,
                  decoration: const InputDecoration(labelText: 'దిశ'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Across',
                      child: Text('Across - అడ్డంగా'),
                    ),
                    DropdownMenuItem(
                      value: 'Down',
                      child: Text('Down - నిలువుగా'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => direction = value);
                    }
                  },
                ),
                TextField(
                  controller: clueController,
                  decoration: const InputDecoration(labelText: 'ప్రశ్న'),
                ),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(labelText: 'సమాధానం'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('రద్దు'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('జోడించు'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final number = numberController.text.trim();
      final clue = clueController.text.trim();
      final answer = answerController.text.trim();

      if (number.isNotEmpty && clue.isNotEmpty && answer.isNotEmpty) {
        setState(() {
          final key = '$direction $number';
          clues[key] = clue;
          answers[key] = answer;
        });
      }
    }
  }

  void clearGrid() {
    setState(() {
      blackCells = List.generate(
        size,
        (_) => List.generate(size, (_) => false),
      );
      letters = List.generate(
        size,
        (_) => List.generate(size, (_) => ''),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('పదగమనం'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                '15 × 15 Crossword Editor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'గడిని నొక్కితే అక్షరం రాయవచ్చు. నల్ల గడిగా మార్చడానికి ఎక్కువసేపు నొక్కండి.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 5,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ),
                      itemCount: size * size,
                      itemBuilder: (context, index) {
                        final row = index ~/ size;
                        final col = index % size;

                        return GestureDetector(
                          onTap: () => editLetter(row, col),
                          onLongPress: () => toggleCell(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: blackCells[row][col]
                                  ? Colors.black
                                  : Colors.white,
                              border: Border.all(
                                color: Colors.blueGrey,
                                width: 0.4,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                letters[row][col],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: addClue,
                  icon: const Icon(Icons.add),
                  label: const Text('ప్రశ్న జోడించు'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Grid క్లియర్ చేయాలా?'),
                        content: const Text(
                          'అన్ని అక్షరాలు, నల్ల గడులు తొలగిపోతాయి.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('వద్దు'),
                          ),
                          FilledButton(
                            onPressed: () {
                              clearGrid();
                              Navigator.pop(context);
                            },
                            child: const Text('క్లియర్'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('క్లియర్'),
                ),
              ],
            ),
            Expanded(
              flex: 3,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  const Text(
                    'ప్రశ్నలు & సమాధానాలు',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (clues.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('ఇంకా ప్రశ్నలు జోడించలేదు.'),
                    ),
                  ...clues.entries.map(
                    (entry) => Card(
                      child: ListTile(
                        title: Text('${entry.key}: ${entry.value}'),
                        subtitle: Text('సమాధానం: ${answers[entry.key]}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              answers.remove(entry.key);
                              clues.remove(entry.key);
                            });
                          },
                        ),
                      ),
                    ),
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
