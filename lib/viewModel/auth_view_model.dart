// ignore_for_file: library_prefixes, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:sellers_app/global/global_vars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/mainScreens/home_screen.dart';

class AuthViewModel {
  Future<void> validateSignUpForm(
      XFile? imageXFile,
      String password,
      String confirmPassword,
      String name,
      String email,
      String phone,
      String locationAddress,
      BuildContext context) async {
    if (imageXFile == null) {
      commonViewModel.showSnackBar("Please select an image", context);
      return;
    }

    if (password != confirmPassword) {
      commonViewModel.showSnackBar("Passwords do not match", context);
      return;
    }

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty ||
        locationAddress.isEmpty) {
      commonViewModel.showSnackBar("Please fill all the fields", context);
      return;
    }

    try {
      User? currentFirebaseUser =
          await createUserInFirebaseAuth(email, password, context);
      if (currentFirebaseUser != null) {
        String downloadUrl = await uploadImageToStorage(imageXFile);
        await saveUserInfoToDatabase(currentFirebaseUser, downloadUrl, name,
            email, phone, locationAddress, context);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      }
    } catch (error) {
      commonViewModel.showSnackBar("Error during sign up: $error", context);
    }
  }

  Future<User?> createUserInFirebaseAuth(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (errorMsg) {
      commonViewModel.showSnackBar(errorMsg.toString(), context);
      return null;
    }
  }

  Future<String> uploadImageToStorage(XFile imageXFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
          .ref()
          .child("sellersImages")
          .child(fileName);
      fStorage.UploadTask uploadTask =
          storageRef.putFile(File(imageXFile.path));
      fStorage.TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      throw Exception("Failed to upload image: $error");
    }
  }

  Future<void> saveUserInfoToDatabase(
      User currentFirebaseUser,
      String downloadUrl,
      String name,
      String email,
      String phone,
      String locationAddress,
      BuildContext context) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(currentFirebaseUser.uid)
          .set({
        "sellerUID": currentFirebaseUser.uid,
        "sellerEmail": email,
        "sellerName": name,
        "sellerimage": downloadUrl,
        "phone": phone,
        "address": locationAddress,
        "status": "approved",
        "earning": "0.0",
        "lat": position.latitude,
        "lng": position.longitude
      });

      sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
      await sharedPreferences!.setString("email", email);
      await sharedPreferences!.setString("name", name);
      await sharedPreferences!.setString("photoUrl", downloadUrl);
      await sharedPreferences!.setString("phone", phone);
      await sharedPreferences!.setString("address", locationAddress);

      commonViewModel.showSnackBar("Account has been created", context);
    } catch (error) {
      throw Exception("Error saving user info: $error");
    }
  }
}
