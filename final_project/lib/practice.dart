import 'package:flutter/material.dart';
import 'word_entry.dart'; // WordEntry 클래스를 가져옵니다.

class PracticePage extends StatefulWidget {
  final List<WordEntry> vocabularyList;

  PracticePage({required this.vocabularyList});

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  bool _isSwapped = false;

  void _swapWordAndMeaning() {
    setState(() {
      _isSwapped = !_isSwapped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('연습'),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: _swapWordAndMeaning,
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: widget.vocabularyList.length,
        itemBuilder: (context, index) {
          WordEntry wordEntry = widget.vocabularyList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text(
                _isSwapped ? wordEntry.meaning : wordEntry.word,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    _isSwapped ? wordEntry.word : wordEntry.meaning,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 0); // 줄 간격을 최소화하기 위해 SizedBox 사용
        },
      ),
    );
  }
}
