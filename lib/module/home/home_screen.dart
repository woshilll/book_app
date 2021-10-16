import 'package:book_app/module/home/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("书架"),
        centerTitle: true,
      ),
      body: const Text("主页"),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: ElevatedButton(
          child: const Text("搜书", style: TextStyle(fontSize: 14)),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(const CircleBorder()),
          ),
          onPressed: () {},
        ),
      ),
    );
  }

}
