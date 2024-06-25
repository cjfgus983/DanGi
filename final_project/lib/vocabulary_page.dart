import 'package:flutter/material.dart';
import 'word_entry.dart'; // WordEntry 클래스를 가져옵니다.

class VocabularyPage extends StatefulWidget {
  final List<WordEntry> vocabularyList;
  final Function(String) deleteWord;

  VocabularyPage({required this.vocabularyList, required this.deleteWord});

  @override
  _VocabularyPageState createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  late List<WordEntry> _vocabularyList;
  bool _isSortedByDate = true; // 기본 정렬 기준: 날짜순
  String _searchQuery = ""; // 검색어
  bool _isSearchVisible = false; // 검색창 표시 여부
  final TextEditingController _searchController =
      TextEditingController(); // 검색어 컨트롤러

  @override
  void initState() {
    super.initState();
    _vocabularyList = List.from(widget.vocabularyList);
    _sortVocabularyList();
  }

  void _sortVocabularyList() {
    setState(() {
      if (_isSortedByDate) {
        _vocabularyList.sort((a, b) => a.date.compareTo(b.date)); // 날짜 순으로 정렬
      } else {
        _vocabularyList.sort((a, b) => a.word.compareTo(b.word)); // 알파벳 순으로 정렬
      }
    });
  }

  void deleteWord(String word) {
    setState(() {
      _vocabularyList.removeWhere((entry) => entry.word == word);
    });
    widget.deleteWord(word); // 메인의 deleteWord함수 실행
  }

  void _toggleSort() {
    setState(() {
      _isSortedByDate = !_isSortedByDate; // 정렬 기준 토글
      _sortVocabularyList(); // 정렬 리스트 업데이트
    });
  }

  List<WordEntry> _filterVocabularyList() {
    if (_searchQuery.isEmpty) {
      return _vocabularyList;
    } else {
      return _vocabularyList
          .where((entry) =>
              entry.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              entry.meaning.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<WordEntry> filteredList = _filterVocabularyList();

    return Scaffold(
      appBar: AppBar(
        title: Text('단어장'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(_isSortedByDate
                ? Icons.sort_by_alpha
                : Icons.date_range), // 정렬 기준에 따라 아이콘 변경
            onPressed: _toggleSort, // 정렬 기준 변경
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchVisible)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '단어 또는 뜻 검색',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                WordEntry wordEntry = filteredList[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      wordEntry.word,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ), // 단어의 글자 크기 조정
                    ),
                    subtitle: Text(
                      wordEntry.meaning,
                      style: TextStyle(fontSize: 14), // 단어 뜻의 글자 크기 조정
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${wordEntry.date.month.toString().padLeft(2, '0')}-${wordEntry.date.day.toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteWord(wordEntry.word);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 0); // 줄 간격을 최소화하기 위해 SizedBox 사용
              },
            ),
          ),
        ],
      ),
    );
  }
}
