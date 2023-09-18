import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:project/src/common_widgets/api_constanst/api_constanst.dart';
import 'package:project/src/features/core/controllers/user_controller.dart';
import 'package:project/src/features/authentication/models/user_model.dart';
import 'package:project/src/features/core/models/dashboard/history_model.dart';
import 'package:project/src/features/core/models/dashboard/result.dart';

class SkinDetectController extends GetxController {
  var selectedImagePath = ''.obs;
  var selectedImageSize = ''.obs;
  final getImageURL = APIConstants.getImageUrl;
  final historyURL = APIConstants.getHistoryUrl;
  Rx<Result?> result = Rx<Result?>(null);
  User? userModel;
  HistoryModel? hitoryModel;

  final UserController userController = Get.find<UserController>();

  Rx<Color?> cardColor = Colors.greenAccent[100].obs;
  Rx<Color?> subCircle = Colors.green[500].obs;
  // list of history
  final historyList = RxList<HistoryModel>([]);
  Rx<User?> currentUser = Rx<User?>(null); // Updated currentUser

  void updateUser(User? user) {
    currentUser.value = user;
  }

  void getImage(ImageSource imageSource) async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: imageSource);

    if (pickedFile != null) {
      selectedImagePath.value = pickedFile.path;
    } else {
      Get.snackbar("Error", "No image selected",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> uploadImage() async {
    final file = File(selectedImagePath.value);
    if (!file.existsSync()) {
      Get.snackbar("Error", "Image not found",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      const confidenceScore = 0.9;
      final userModel = userController.getUserModel;
      final userId = userModel?.userId.toString();
      final body = {
        'file': base64Image,
        'confidence_score': confidenceScore.toString(),
        'user_id': userId,
      };
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      final response = await http.post(
        getImageURL,
        body: body,
        headers: headers,
      );

      // Handle the API response
      if (response.statusCode == 200) {
        // Success
        print('Image uploaded successfully');
        final jsonResponse = jsonDecode(response.body);
        result.value = Result.fromJson(jsonResponse);
        print('Placement: ${result.value!.placement}');
        print('Score: ${result.value!.score}');
        calculateScoreAndSetCardColor();
        calculateScoreAndSetCardColorSubCircle();
        // load the history after successful upload
        // create a new history item from the api response
        final newHistoryItem = HistoryModel.fromJson(jsonResponse);
        historyList.add(newHistoryItem);

        Get.back();
      } else {
        // Error
        print('Failed to upload image. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred while uploading image: $e');
    } finally {
      Get.back(); // Close the progress dialog
    }
  }

  Result? getResult() {
    return result.value;
  }

  void calculateScoreAndSetCardColor() {
    double? scoreApi = result.value?.score;
    print("scoreApi: $scoreApi");
    if (scoreApi != null) {
      if (scoreApi < 0.49) {
        cardColor.value = Colors.greenAccent[100];
      } else if (scoreApi >= 0.5 && scoreApi < 0.79) {
        cardColor.value = Colors.orangeAccent[100];
      } else {
        cardColor.value = Colors.redAccent[100];
      }
    }
  }

  void calculateScoreAndSetCardColorSubCircle() {
    double? scoreApi = result.value?.score;
    print("scoreApi: $scoreApi");
    if (scoreApi != null) {
      if (scoreApi < 0.49) {
        subCircle.value = Colors.green[500];
      } else if (scoreApi >= 0.5 && scoreApi < 0.79) {
        subCircle.value = Colors.orange[500];
      } else {
        subCircle.value = Colors.red[500];
      }
    }
  }

  // load list of history
  Future<void> fetchHistory() async {
    final userModel = userController.getUserModel;
    final userId = userModel?.userId.toString();
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = {
      'user_id': userId,
    };

    try {
      final response = await http.post(
        historyURL,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataReceived = jsonDecode(response.body);
        final String result = dataReceived['placement'];

        final List<dynamic> historyData = jsonDecode(result);

        if (historyData.isNotEmpty) {
          final List<HistoryModel> history = historyData.map((e) {
            return HistoryModel.fromJson(e);
          }).toList();
          historyList.assignAll(history);
        }
      }

      // Handle other status codes or unexpected responses
      throw Exception('Failed to fetch history');
    } catch (e) {
      // Handle exceptions, e.g., network errors
      print('Error: $e');
      throw Exception('An error occurred while fetching history');
    }
  }
}
