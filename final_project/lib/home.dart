import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'vocabulary_page.dart';
import 'word_entry.dart'; // WordEntry 클래스를 가져옵니다.
import 'practice.dart';
import 'contribution_page.dart'; // ContributionPage를 가져옵니다.
import 'test.dart';

class HomePage extends StatelessWidget {
  final List<WordEntry> vocabularyList;
  final Function(String) deleteWord; // 단어를 삭제하는 함수를 추가

  HomePage({required this.vocabularyList, required this.deleteWord});

  final PageController _controller = PageController();
  // 1. 단어 리스트 2. 단어 삭제 함수 3. 페이지 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              children: [
                HomeButton(
                  icon: Icons.book,
                  label: '단어장',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyPage(
                          vocabularyList: vocabularyList,
                          deleteWord: deleteWord,
                        ),
                      ),
                    );
                  },
                ),
                HomeButton(
                  icon: Icons.edit,
                  label: '연습',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PracticePage(vocabularyList: vocabularyList),
                      ),
                    );
                  },
                ),
                HomeButton(
                  icon: Icons.calendar_today,
                  label: '공부빈도',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ContributionPage(vocabularyList: vocabularyList),
                      ),
                    );
                  },
                ),
                HomeButton(
                  icon: Icons.question_answer,
                  label: '테스트',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TestPage(vocabularyList: vocabularyList),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 4,
              effect: WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: Color.fromARGB(255, 92, 107, 191),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          child: Container(
            width: 300,
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 100,
                ),
                SizedBox(height: 20),
                Text(
                  label,
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
