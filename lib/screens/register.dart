import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/forgot_password.dart';
import 'package:users/screens/login.dart';
import 'package:users/screens/main_screen.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;

  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ).then((auth) async {

        
        currentUser = auth.user;
        if (currentUser != null) {
          Map userMap = {
            'id': currentUser!.uid,
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'address': addressController.text.trim(),
          };
          
          DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users');
          userRef.child(currentUser!.uid).set(userMap);
      }

      await Fluttertoast.showToast(msg: "Registration Successful");
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
        FocusScope.of(context).unfocus();
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
              'Register',
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
                            LengthLimitingTextInputFormatter(50),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Name',
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
                              return 'Please enter your name';
                            }
                            if (text.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            if (text.length > 50) {
                              return 'Name must be less than 50 characters';
                            }
                          },
                          onChanged: (text) => setState(() {
                            nameController.text = text;
                          }),
                        ),
                        SizedBox(height: 10),

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
                        SizedBox(height: 10),

                        IntlPhoneField(
                          showCountryFlag: false,
                          dropdownIcon: Icon(
                            Icons.arrow_drop_down,
                            color: darkTheme
                                ? Colors.amber.shade400
                                : Colors.grey,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Phone',
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
                          ),
                          initialCountryCode: 'VN',
                          onChanged: (text) => setState(() {
                            phoneController.text = text.completeNumber;
                          }),
                        ),

                        TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(150),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Address',
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
                              return 'Please enter your Address';
                            }
                            if (text.length < 2) {
                              return 'Address must be at least 2 characters';
                            }
                            if (text.length > 50) {
                              return 'Address must be less than 50 characters';
                            }
                          },
                          onChanged: (text) => setState(() {
                            addressController.text = text;
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
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                              ),
                              onPressed: () {
                                // update the state to toggle password visibility
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },

                            )
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

                         TextFormField(
                          obscureText: !_passwordVisible,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          decoration: InputDecoration(
                            hintText: ' Confirm Password',
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
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                              ),
                              onPressed: () {
                                // update the state to toggle password visibility
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },

                            )
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please enter your Confirm Password';
                            }

                            if (text != passwordController.text) {
                              return 'Confirm Password must match Password';
                            }
                            if (text.length < 6) {
                              return 'Confirm Password must be at least 6 characters';
                            }
                            if (text.length > 50) {
                              return 'Confirm Password must be less than 50 characters';
                            }
                            return null;
                          },
                          onChanged: (text) => setState(() {
                            confirmPasswordController.text = text;
                          }),
                        ),

                        SizedBox(height: 20,),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
                            foregroundColor: darkTheme ? Colors.black : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: (){
                            _submit();
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(
        builder: (c) => ForgotPasswordScreen()));
                          },
                          child : Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Have an account? ",
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
                                "Sign In",
                                style:TextStyle(
                                  fontSize: 15,
                                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                ),
                              ),
                            )
                          ],
                        )

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
