import 'package:flutter/material.dart';

class TasbeehCounter extends StatefulWidget {
  const TasbeehCounter({super.key});

  @override
  State<TasbeehCounter> createState() => _TasbeehCounterState();
}

class _TasbeehCounterState extends State<TasbeehCounter> {
  String? selectedItem;
  int? selectedCount;

  final List<String> options = [
    "SubhanAllah",
    "Alhamdulillah",
    "Allahu Akbar",
    "Ayah Count",
    "Hadith Count",
    "Dua Count",
    "Custom",
  ];

  void _showCustomDialog() {
    String customLabel = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Enter custom label to count it"),
              content: TextField(
                onChanged: (value) {
                  setDialogState(() {
                    customLabel = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: "e.g. Ayat e Karima",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: customLabel.isEmpty
                      ? null
                      : () {
                          setState(() {
                            options.add(customLabel);
                            selectedItem = customLabel; // set value before navigating
                          });
                          Navigator.of(context).pop();
                        },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _goToNextScreen() {
    if (selectedItem != null && selectedCount != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Counter(
            maxCount: selectedCount!,
            textTasbeeh: selectedItem!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select both item and count"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasbeeh Counter"),
        leading: const Icon(Icons.arrow_back),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedItem,
              hint: const Text("Select what to count"),
              items: options.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue == "Custom") {
                  _showCustomDialog(); // show dialog, don't set yet
                } else {
                  setState(() {
                    selectedItem = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [33, 99, 200, 500].map((count) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedCount == count ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedCount = count;
                    });
                  },
                  child: Text("$count"),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToNextScreen,
              child: const Text("Next ->"),
            ),
          ],
        ),
      ),
    );
  }
}

class Counter extends StatefulWidget {
  final int maxCount;
  final String textTasbeeh;

  const Counter({super.key, required this.maxCount, required this.textTasbeeh});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int currentCount = 0;

  void increment() {
    if (currentCount < widget.maxCount) {
      setState(() => currentCount++);
    }
    else if(currentCount==widget.maxCount) {

      showDialog(context: context,barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: Text("You completed the tasbeeh!"),
          content: Text("May Allah reward you"),
          actions: [
            TextButton(onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }, child: Text("OK"))
          ],
        );
      });
    }
   
  }

  @override
  Widget build(BuildContext context) {
    double progress = currentCount / widget.maxCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.textTasbeeh), //  show selected text here
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  "$currentCount/${widget.maxCount}",
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: increment,
              child: const Text("Increment"),
            ),
          ],
        ),
      ),
    );
  }
}
