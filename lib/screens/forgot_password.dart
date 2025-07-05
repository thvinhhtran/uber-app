import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

   final emailController = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    void _submit() {
      firebaseAuth.sendPasswordResetEmail(
        email: emailController.text.trim()).then((value){
          Fluttertoast.showToast(msg:"We have sent you an email to reset your password");
        }).onError((error, StackTrace) {
          Fluttertoast.showToast(msg: error.toString());
        });
    }
  @override
  Widget build(BuildContext context) {

     bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
   return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard on tap outside
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Image.asset(
              darkTheme
                  ? 'images/assets/city_dark.jpeg'
                  : 'images/assets/city.jpeg',
            ),
            SizedBox(height: 20),
            Text(
              'Forgot Password',
              style: TextStyle(
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(150),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme
                                ? Colors.black45
                                : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            prefix: Icon(
                              Icons.person,
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.grey,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please enter your Email';
                            }
                            if (EmailValidator.validate(text) == true) {
                              return null;
                            }
                            if (text.length < 2) {
                              return 'Email must be at least 2 characters';
                            }
                            if (text.length > 50) {
                              return 'Email must be less than 50 characters';
                            }
                          },
                          onChanged: (text) => setState(() {
                            emailController.text = text;
                          }),
                        ),
                        SizedBox(height: 20),

                      

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTheme
                                ? Colors.amber.shade400
                                : Colors.blue,
                            foregroundColor: darkTheme
                                ? Colors.black
                                : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            _submit();
                          },
                          child: Text(
                            'Send Reset Password Link', // Changed text to be more descriptive
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.blue,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "have an account?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                 Navigator.push(context, MaterialPageRoute(
        builder: (c) => LoginScreen()));
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}