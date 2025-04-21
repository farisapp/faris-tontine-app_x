import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {

  PageController pageController = PageController();
  RxInt currentIndex = 0.obs;


  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  changePage(int index){
    print("index => $index");
    currentIndex.value = index;
    update();
  }
}