import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/src/constants/size.dart';
import 'package:project/src/constants/text_string.dart';
import 'package:project/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:project/src/features/core/screens/dashboard/widgets/banner.dart';
import 'package:project/src/features/core/screens/dashboard/widgets/categories.dart';
import 'package:project/src/features/core/screens/dashboard/widgets/search.dart';
import 'package:project/src/features/core/screens/dashboard/widgets/top_skincancer.dart';
import 'package:project/src/features/core/screens/detect/skin_detect_screen.dart';

import '../../controllers/user_controller.dart';
import '../dashboard/widgets/navigation_bar.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    UserController userController = Get.put(UserController());
    final userModel = userController.getUserModel;
    final user_name = userModel?.userName.toString();
    return SafeArea(
      child: Scaffold(
        appBar: const DashboardAppBar(),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefaultSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Heading
                Text(
                  "Hey $user_name",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                //search box
                DashboardSearchBox(),
                SizedBox(
                  height: 20,
                ),

                //categories
                DashboardCategories(),
                SizedBox(
                  height: 20,
                ),

                //banner
                DashboardBanners(),
                SizedBox(
                  height: 20,
                ),

                Text(
                  tDashboardSkincanncer,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                //Top skin cancer
                DashboardTopSkincancer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
