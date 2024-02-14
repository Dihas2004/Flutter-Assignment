import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/services/firebase_auth_services.dart';
import 'package:movie_app/screens/login.dart';
import 'package:movie_app/widgets/form_container_widget.dart';
import 'package:movie_app/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("SignUp"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap:  () async{
                  _signUp();
                  

                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isSigningUp ? CircularProgressIndicator(color: Colors.white,):
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage()),
                          (route) => false);
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {

setState(() {
  isSigningUp = true;
});

    String Username = _usernameController.text;
    String Email = _emailController.text;
    String Password = _passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(Email, Password);

setState(() {
  isSigningUp = false;
});
    if (user != null) {
      showToast(message: "User is successfully created");
      _createData(UserModel(
        username:Username,
        password:Password,
        email:Email,
      ));

      Navigator.pushNamed(context, "/home");
    } else {
      showToast(message: "Some error happend");
    }
  }
}



void _createData(UserModel userModel) {
    final userCollection = FirebaseFirestore.instance.collection("users");

    String id = userCollection.doc().id;

    final newUser = UserModel(
      username: userModel.username,
      password: userModel.password,
      email: userModel.email,
        id: id,
    ).toJson();

    userCollection.doc(id).set(newUser);
  }

  class UserModel{
  final String? username;
  final String? email;
  final String? password;
  final String? id;

  UserModel({this.id,this.username, this.email, this.password});


  static UserModel fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot){
    return UserModel(
      username: snapshot['username'],
      email: snapshot['email'],
      password: snapshot['password'],
      id: snapshot['id'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "username": username,
      "password": password,
      "id": id,
      "email": email,
    };
  }
}