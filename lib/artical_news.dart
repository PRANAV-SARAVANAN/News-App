import 'package:flutter/material.dart';

class ArticalNews extends StatefulWidget {
  const ArticalNews({super.key});

  @override
  State<ArticalNews> createState() => _ArticalNewsState();
}

class _ArticalNewsState extends State<ArticalNews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg-blue-grad.png'),
            fit: BoxFit.cover,
          ),
        ),
        
      ),);
  }
}