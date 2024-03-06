import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_app/screens/sign_up.dart';
import 'package:movie_app/services/firebase_auth_services.dart';
import 'package:movie_app/widgets/form_container_widget.dart';
import 'package:movie_app/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? globalUserId;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  bool _rememberMe = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeLoginStatus();
    //_initializeSavedEmail();
  }

  void _initializeSavedEmail() async {
    String? savedEmail = await getSavedEmailFromSharedPreferences();
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text(
                "Login",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom:8.0),
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom:6.0),
                    child: Text("Remember Me"),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  _signIn();
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isSigning
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  _signInWithGoogle();
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.google,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveLoginStatusToSharedPreferences(bool isLoggedIn) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('login_status', isLoggedIn);
}

Future<bool> getLoginStatusFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('login_status') ?? false;
}

Future<void> saveUserIDToSharedPreferences(String userID) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_id', userID);
}



  void _initializeLoginStatus() async {
  bool isLoggedIn = await getLoginStatusFromSharedPreferences();
  print(isLoggedIn);
  if (isLoggedIn) {
    // User is already logged in, navigate to the home page or perform other actions
    Navigator.pushNamed(context, "/home");
  }
}


  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      // Save email to shared preferences
      //saveLoginStatusToSharedPreferences(true);
      if (_rememberMe) {
      saveLoginStatusToSharedPreferences(true);
    }

      //saveEmailToSharedPreferences(email);

      // Get user document from Firestore using the email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User found in Firestore
        String userId = querySnapshot.docs.first.id;
        globalUserId = userId;
        saveUserIDToSharedPreferences(userId);
        print('User ID: $userId');
        showToast(message: "User is successfully signed in");

        // Navigate to home page or perform other actions as needed
        Navigator.pushNamed(context, "/home");
      } else {
        // User not found in Firestore
        showToast(message: "User not found");
      }
    } else {
      showToast(message: "Some error occurred");
    }
  }

  _signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '900028268549-7h85d0hkc0qb0c79u29uqnc3akop8map.apps.googleusercontent.com',
);

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential userCredential = await  _firebaseAuth.signInWithCredential(credential);

         if (userCredential.user != null) {
        showToast(message: "Signed in with Google successfully");
        _createData(UserModel(
          id: userCredential.user!.uid,
          username: googleSignInAccount.displayName ?? "",
          email: googleSignInAccount.email ?? "",
        ));
        String email = googleSignInAccount.email;
        

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User found in Firestore
        String userId = querySnapshot.docs.first.id;
        globalUserId = userId;
        saveUserIDToSharedPreferences(userId);
        print('User ID: $userId');
        showToast(message: "User is successfully signed in");

        // Navigate to home page or perform other actions as needed
        Navigator.pushNamed(context, "/home");
      }
      }
      }
    } catch (e) {
      showToast(message: "some error occurred $e");
    }
  }

  Future<void> saveEmailToSharedPreferences(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_email', email);
  }

  Future<String?> getSavedEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_email');
  }
}

Future<void> _createData(UserModel userModel) async {
  final userCollection = FirebaseFirestore.instance.collection("users");

  // Check if the user already exists based on the UID
  final existingUserDoc = await userCollection.doc(userModel.id!).get();

  if (!existingUserDoc.exists) {
    // User does not exist, create a new user model
    userCollection.doc(userModel.id).set(userModel.toJson());
  } else {
    // User already exists, you can update the existing user model if needed
    // Or handle the situation according to your requirements
    print("User with ID ${userModel.id} already exists in Firestore");
  }
}
