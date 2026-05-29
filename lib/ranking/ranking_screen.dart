import 'package:flutter/material.dart';
//import 'package:flutter_application_1/ranking/widgets/ranking_list.dart';

void main() {
  runApp(const RankingPreview());
}

class RankingPreview extends StatelessWidget {
  const RankingPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ranking App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      
    );
  }
}