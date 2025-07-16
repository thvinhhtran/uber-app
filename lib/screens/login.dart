import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/forgot_password.dart';
import 'package:users/screens/main_screen.dart';
import 'package:users/screens/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _passwordVisible = false;

  // declare form key
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ).then((auth) async {
        currentUser = auth.user;

      await Fluttertoast.showToast(msg: "Login Successful");
      Navigator.push(context, MaterialPageRoute(
        builder: (c) => MainScreen()));
      }).catchError((errormassege){
          Fluttertoast.showToast(msg: "Error: " + errormassege.toString());
      });
    }

    else {
      Fluttertoast.showToast(msg: "Please fill all fields correctly");
    }
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
              'Login',
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

                        TextFormField(
                          obscureText: !_passwordVisible,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Password',
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                // update the state to toggle password visibility
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please enter your Password';
                            }
                            if (text.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            if (text.length > 50) {
                              return 'Password must be less than 50 characters';
                            }
                            return null;
                          },
                          onChanged: (text) => setState(() {
                            passwordController.text = text;
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
                            'Login', // Đổi từ Register thành Login
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(
        builder: (c) => ForgotPasswordScreen()));
                          },
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
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                // Chuyển sang trang Register
                                 Navigator.push(context, MaterialPageRoute(
        builder: (c) => RegisterScreen()));
                              },
                              child: Text(
                                "Register",
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
