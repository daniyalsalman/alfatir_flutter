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
        return AlertDialog(
          title: Text("enter custom label to count it"),
          content: TextField(
            onChanged: (value) {
              customLabel = value;
            },
            decoration: InputDecoration(hint: Text("e.g Ayat e Karima")),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (customLabel.isNotEmpty) {
                  setState(() {
                    selectedItem = customLabel;
                  });
                  Navigator.of(context).pop;
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasbeeh Counter"),
        leading: Icon(Icons.arrow_back),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedItem,
              hint: Text("Select what to count"),
              items: options.map((item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedItem = newValue;
                  if (newValue == "Custom") {
                    // show dialog to enter custom label
                    _showCustomDialog();
                  }
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCount = 33;
                    });
                  },
                  child: Text("33"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCount = 99;
                    });
                  },
                  child: Text("99"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCount = 200;
                    });
                  },
                  child: Text("200"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCount = 500;
                    });
                  },
                  child: Text("500"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Counter()),
                );
              },
              child: Text("Next ->"),
            ),
          ],
        ),
      ),
    );
  }
}

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
