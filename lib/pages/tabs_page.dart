import 'package:chatgpt_clone/pages/gemini.dart';
import 'package:chatgpt_clone/pages/chat_gpt.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  final List<Widget> _pages = [
    const ChatGptPage(),
    const ChatGemini(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
              selectedColor: Colors.green,
              unselectedColor: Colors.grey,
              icon: const Icon(Icons.chat),
              title: const Text("Home"),
            ),
            SalomonBottomBarItem(
              selectedColor: Colors.red,
              unselectedColor: Colors.grey,
              icon: const Icon(Icons.chat_sharp),
              title: const Text("Add"),
            ),
          ]),
    );
  }
}
