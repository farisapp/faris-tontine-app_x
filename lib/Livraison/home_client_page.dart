import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/Livraison/find_courier_page.dart';
import 'package:faris/Livraison/courses_page.dart';

class HomeClientPage extends StatelessWidget {
  const HomeClientPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFFFFF8E1), // très clair
              Color(0xFFFFE0B2), // clair doux
              Color(0xFFFFA726), // plus doux que F57C00
            ],
            stops: [0.2, 0.7, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 10),
                      Text(
                        "Espace Client",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildButtonsRow(context, [
                    _buildCircleButton(
                      context: context,
                      text: "Trouver un livreur",
                      iconPath: "assets/images/find_delivery.png",
                      onPressed: () => Get.to(() => FindCourierPage()),
                    ),
                    _buildCircleButton(
                      context: context,
                      text: "Mes demandes",
                      iconPath: "assets/images/mes_demandes_courses.png",
                      onPressed: () => Get.to(() => CoursesPage()),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonsRow(BuildContext context, List<Widget> buttons) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: buttons,
    );
  }

  Widget _buildCircleButton({
    required BuildContext context,
    required String text,
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double circleRadius = screenWidth * 0.15;

    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.deepOrange, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
              ],
            ),
            child: CircleAvatar(
              radius: circleRadius,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: SizedBox(
                  width: circleRadius * 2,
                  height: circleRadius * 2,
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: Text(
              text,
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
