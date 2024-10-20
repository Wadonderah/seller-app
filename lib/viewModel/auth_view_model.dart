import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global_instances.dart';

class AuthViewModel {
  validateSignUpForm(
      XFile? imageFile,
      String password,
      String confirmPsssword,
      String name,
      String email,
      String phone,
      String locationAddress,
      BuildContext context) {
    if (imageFile == null) {
      commonViewModel.showSnackBar("Please select an image", context);
      return;
    } else {
      if (password == confirmPsssword) {
        if (name.isNotEmpty &&
            email.isNotEmpty &&
            password.isNotEmpty &&
            confirmPsssword.isNotEmpty &&
            phone.isNotEmpty &&
            locationAddress.isNotEmpty) {
          //signup
          createUserInFirebaseAuth(email, password);
        } else {
          commonViewModel.showSnackBar("Please fill all the details", context);
          return;
        }
      } else {
        commonViewModel.showSnackBar(
            "Password and confirm password should be same", context);
        return;
      }
    }
  }

  createUserInFirebaseAuth(String email, String password) async {}
}
