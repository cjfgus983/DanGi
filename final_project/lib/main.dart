import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'home.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'word_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 플러터 위젯 바인딩 초기화
  await Hive.initFlutter(); // Hive 초기화
  Hive.registerAdapter(WordEntryAdapter()); // WordEntry 어댑터 등록
  await Hive.openBox<WordEntry>('vocabularyBox'); // vocabularyBox 열기
  await Hive.openBox('settingsBox'); // settingsBox 열기 - 다크모드
  runApp(MyApp()); // MyApp 실행
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

//다크모드 설정=============================================================
class _MyAppState extends State<MyApp> {
  late bool _isDarkMode; // 다크 모드 상태 변수
  late Box settingsBox; // 설정 저장
  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settingsBox'); // settingsBox 초기화
    _isDarkMode =
        settingsBox.get('isDarkMode', defaultValue: false); // 다크모드 상태 가져오기
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode; // 다크 모드 상태 토글
      settingsBox.put('isDarkMode', _isDarkMode); // 다크 모드 상태 저장
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨기기
      theme:
          _isDarkMode ? ThemeData.dark() : ThemeData.light(), // 다크 모드/라이트 모드 설정
      home: VocabularyApp(
          toggleTheme: _toggleTheme,
          isDarkMode: _isDarkMode), // VocabularyApp 화면 설정
    );
  }
}

class VocabularyApp extends StatefulWidget {
  final VoidCallback toggleTheme; // 다크 모드 토글 함수
  final bool isDarkMode; // 다크 모드 상태

  VocabularyApp({required this.toggleTheme, required this.isDarkMode});

  @override
  _VocabularyAppState createState() => _VocabularyAppState();
}

// 캘린더와 단어 관리 ============================================
class _VocabularyAppState extends State<VocabularyApp> {
  TextEditingController _wordInputController =
      TextEditingController(); // 단어 입력 input
  TextEditingController _meaningInputController =
      TextEditingController(); // 뜻 입력 input
  List<WordEntry> _vocabularyList = []; // 단어 목록 모든 단어 저장할 리스트
  DateTime _selectedDay = DateTime.now(); // 선택된 날짜
  bool _showCalendar = true; // 캘린더 표시 여부
  int _selectedIndex = 0; // 선택된 인덱스
  PageController _pageController = PageController(); // 페이지 컨트롤러
  late Box<WordEntry> _vocabularyBox; // 단어를 저장할 박스

  @override
  void initState() {
    super.initState();
    _vocabularyBox = Hive.box<WordEntry>('vocabularyBox'); // vocabularyBox 초기화
    _wordInputController.addListener(_showHideCalendar); // 단어 입력 리스너 추가
    _meaningInputController.addListener(_showHideCalendar); // 뜻 입력 리스너 추가
    _loadVocabularyList(); // 단어 목록 로드
  }

  void _showHideCalendar() {
    setState(() {
      _showCalendar = _wordInputController.text.isEmpty &&
          _meaningInputController
              .text.isEmpty; // 두 인풋이 비어있으면 showCalendar를 true로
    });
  }

  //WordEntry 형식의 리스트에 단어 추가 ==================================================
  void addWord() {
    String word = _wordInputController.text.trim(); // 입력된 단어
    String meaning = _meaningInputController.text.trim(); // 입력된 뜻
    if (word.isEmpty || meaning.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('알림'),
          content: Text('단어와 뜻을 모두 입력하세요!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }
    final newWord = WordEntry(
      word: word,
      meaning: meaning,
      date: _selectedDay,
    );
    _vocabularyBox.add(newWord); // WordEntry 형식의 박스 ------- 하이브에 저장

    setState(() {
      // ------------------------ list에 저장하고 입력 했으니 input 클리어
      _vocabularyList.add(newWord); // 단어 목록에 추가
      _wordInputController.clear(); // 단어 입력 필드 초기화
      _meaningInputController.clear(); // 뜻 입력 필드 초기화
    });

    FocusScope.of(context).unfocus(); // 포커스 해제
  }

  void deleteWord(String word) {
    final wordToDelete =
        _vocabularyBox.values.firstWhere((entry) => entry.word == word);
    wordToDelete.delete();
    // 하이브에서 단어 삭제=========================
    // 리스트에서도 삭제=============================
    setState(() {
      _vocabularyList.removeWhere((entry) => entry.word == word);
    });
  }

  List<WordEntry> getWordsForSelectedDay(DateTime day) {
    return _vocabularyList
        .where((entry) => entry.date == day)
        .toList(); // 선택된 날짜와 일치하는 단어 리스트
  }

  // 하단 네비게이터에서 사용하는 함수 2번 인덱스는 다크모드이니 toggleThem실행
  void _onItemTapped(int index) {
    if (index == 2) {
      widget.toggleTheme(); // 다크 모드 토글
    } else {
      setState(() {
        _selectedIndex = index; // 선택된 인덱스 설정
      });
      _pageController.jumpToPage(index); // 페이지 이동
    }
  }

  // 하이브에서 단어 리스트 불러오기
  void _loadVocabularyList() {
    setState(() {
      _vocabularyList = _vocabularyBox.values.toList(); // 단어 목록 로드
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드가 나타날 때 화면이 밀리지 않게
      body: PageView(
        controller: _pageController, // 페이지 컨트롤러 설정
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index; // 선택된 인덱스 업데이트
          });
        },
        children: <Widget>[
          //네비게이터 -- 캘린더
          VocabularyInputPage(
            wordInputController: _wordInputController,
            meaningInputController: _meaningInputController,
            vocabularyList: _vocabularyList,
            selectedDay: _selectedDay,
            showCalendar: _showCalendar,
            showHideCalendar: _showHideCalendar,
            addWord: addWord,
            deleteWord: deleteWord,
            getWordsForSelectedDay: getWordsForSelectedDay,
            onDaySelected: (selectedDay) {
              setState(() {
                _selectedDay = selectedDay; // 선택된 날짜 업데이트
              });
            },
          ),
          // -- 네비게이터 가운데 Home
          HomePage(
            vocabularyList: _vocabularyList,
            deleteWord: deleteWord,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), // 캘린더 아이콘
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // 홈 아이콘
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nightlight_round), // 다크 모드 아이콘
            label: 'Night Mode',
          ),
        ],
        currentIndex: _selectedIndex, // 선택된 인덱스 설정
        selectedItemColor: Color.fromARGB(255, 92, 107, 191), // 선택된 아이템 색상 설정
        onTap: _onItemTapped, // 아이템 탭 핸들러 설정
      ),
    );
  }
}

// ===== 단어 입력 선언부 =====
class VocabularyInputPage extends StatelessWidget {
  final TextEditingController wordInputController; // 단어 입력 컨트롤러
  final TextEditingController meaningInputController; // 뜻 입력 컨트롤러
  final List<WordEntry> vocabularyList; // 단어 목록
  final DateTime selectedDay; // 선택된 날짜
  final bool showCalendar; // 캘린더 표시 여부
  final VoidCallback showHideCalendar; // 캘린더 표시/숨기기 콜백
  final VoidCallback addWord; // 단어 추가 콜백
  final Function(String) deleteWord; // 단어 삭제 콜백
  final List<WordEntry> Function(DateTime)
      getWordsForSelectedDay; // 선택된 날짜의 단어 목록 반환 함수
  final ValueChanged<DateTime> onDaySelected; // 날짜 선택 콜백

  VocabularyInputPage({
    required this.wordInputController,
    required this.meaningInputController,
    required this.vocabularyList,
    required this.selectedDay,
    required this.showCalendar,
    required this.showHideCalendar,
    required this.addWord,
    required this.deleteWord,
    required this.getWordsForSelectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showHideCalendar(); // 캘린더 표시/숨기기
        FocusScope.of(context).unfocus(); // 포커스 해제
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showCalendar)
                TableCalendar(
                  firstDay: DateTime.utc(2021, 10, 16), // 캘린더의 시작 날짜
                  lastDay: DateTime.utc(2030, 3, 14), // 캘린더의 종료 날짜
                  focusedDay: selectedDay, // 포커스된 날짜
                  selectedDayPredicate: (day) {
                    return isSameDay(day, selectedDay); // 선택된 날짜와 같은지 확인
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    onDaySelected(selectedDay); // 날짜 선택 시 콜백 호출
                  },
                ),
              SizedBox(height: 20),
              TextField(
                controller: wordInputController, // 단어 입력 컨트롤러 설정
                decoration: InputDecoration(
                  hintText: '단어 입력', // 힌트 텍스트 설정
                ),
                onTap: () {
                  showHideCalendar(); // 캘린더 표시/숨기기
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: meaningInputController, // 뜻 입력 컨트롤러 설정
                decoration: InputDecoration(
                  hintText: '뜻 입력', // 힌트 텍스트 설정
                ),
                onTap: () {
                  showHideCalendar(); // 캘린더 표시/숨기기
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: addWord,
                child: Text('추가'),
              ),
              SizedBox(height: 20),
              Text(
                '등록된 단어',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // 스크롤 방지
                itemCount:
                    getWordsForSelectedDay(selectedDay).length, // 선택된 날짜의 단어 개수
                itemBuilder: (context, index) {
                  WordEntry wordEntry =
                      getWordsForSelectedDay(selectedDay)[index]; // 선택된 날짜의 단어
                  return ListTile(
                    title: Text(wordEntry.word), // 단어 표시
                    subtitle: Text(wordEntry.meaning), // 뜻 표시
                    trailing: IconButton(
                      icon: Icon(Icons.delete), // 삭제 아이콘
                      onPressed: () => deleteWord(wordEntry.word), // 삭제 콜백 호출
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
