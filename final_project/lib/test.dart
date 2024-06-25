import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'word_entry.dart';

class TestPage extends StatefulWidget {
  final List<WordEntry> vocabularyList;

  TestPage({required this.vocabularyList});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late WordEntry _currentWord;
  late List<String> _options;
  late String _message;
  Timer? _timer;
  double _progress = 1.0;
  static const int _timeLimit = 10; // 10 seconds time limit
  bool _isButtonDisabled = false; // 버튼 비활성화 상태 변수

  @override
  void initState() {
    super.initState();
    if (widget.vocabularyList.length >= 4) {
      _generateNewQuestion();
    } else {
      setState(() {
        _message = '단어가 4개 이상 필요합니다. 단어를 추가해주세요.';
        _isButtonDisabled = true;
      });
    }
  }

  void _startTimer() {
    _progress = 1.0;
    _timer?.cancel(); // timer가 null이 아닐 때 cancel 실행 - 타이머 취소
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress -= 0.1 / _timeLimit;
        if (_progress <= 0) {
          _timer?.cancel();
          _showAnswer();
        }
      });
    });
  }

  void _generateNewQuestion() {
    _timer?.cancel();
    setState(() {
      _message = '';
      _currentWord =
          widget.vocabularyList[Random().nextInt(widget.vocabularyList.length)];
      _options = [_currentWord.meaning];
      while (_options.length < 4) {
        String randomMeaning = widget
            .vocabularyList[Random().nextInt(widget.vocabularyList.length)]
            .meaning;
        if (!_options.contains(randomMeaning)) {
          _options.add(randomMeaning);
        }
      }
      _options.shuffle();
      _isButtonDisabled = false; // 버튼 활성화
      _startTimer(); // Start the timer for each question
    });
  }

  void _showAnswer() {
    setState(() {
      _message = '시간 초과! 정답은 ${_currentWord.meaning}입니다.';
      _isButtonDisabled = true; // 버튼 비활성화
    });
    Future.delayed(Duration(seconds: 2), () {
      _generateNewQuestion();
    });
  }

  void _checkAnswer(String selectedMeaning) {
    _timer?.cancel(); // timer가 null이 아닌경우 cancel() 실행
    setState(() {
      _isButtonDisabled = true; // 버튼 비활성화
      if (selectedMeaning == _currentWord.meaning) {
        _message = '정답입니다!';
      } else {
        _message = '틀렸습니다! 정답은 ${_currentWord.meaning}입니다.';
      }
    });
    Future.delayed(Duration(seconds: 2), () {
      _generateNewQuestion();
    });
  }

  // 타이머 해제할 때 사용
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.vocabularyList.length >= 4) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                _currentWord.word,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ..._options
                  .map((option) => Card(
                        child: ListTile(
                          title: Text(option),
                          onTap: _isButtonDisabled
                              ? null
                              : () => _checkAnswer(option), // 버튼 비활성화 여부 확인
                        ),
                      ))
                  .toList(),
              SizedBox(height: 20),
              Text(
                _message,
                style: TextStyle(
                  fontSize: 18,
                  color: _message == '정답입니다!' ? Colors.green : Colors.red,
                ),
              ),
            ] else ...[
              Text(
                _message,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
