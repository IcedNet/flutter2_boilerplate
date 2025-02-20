import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import '../../../constants/constants.dart';
import '../../../models/models.dart';
import '../../../helpers/helpers.dart';
import 'signUpTextfField.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  static final _signUpFormKey = GlobalKey<FormState>();
  final SignUpValues signUpValues = SignUpValues();
  final lastname = FocusNode();
  final email = FocusNode();
  final password = FocusNode();
  final cpassword = FocusNode();
  final number = FocusNode();
  Widget _button(void Function()? onPressed, String label) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2,
              )
            ],
            gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  void _amplifyRegister(BuildContext context) async {
    try {
      DIOResponseBody response = await AmplifyAuth.amplifyRegisterUser({
        "emailId": signUpValues.email.toString(),
        "password": signUpValues.password,
        "firstName": signUpValues.firstname!.split(' ')[0].toString(),
        "lastName": signUpValues.lastname!.split(' ')[0].toString(),
        "phoneNumber": signUpValues.number.toString(),
        "countryCode": "+61",
      });

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Registered successfully. Please confirm to be signed in.'),
          ),
        );
        Navigator.pushNamed(
            context, '/confirm/${signUpValues.email}/${signUpValues.password}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data),
          ),
        );
      }
    } on UsernameExistsException catch (err) {
      logger.e(err.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message),
        ),
      );
    }
  }

  void _regularRegister(BuildContext context) async {
    DeviceInfo plugin = DeviceInfo();

    DIOResponseBody response = await API().registerUser({
      "firstName": signUpValues.firstname!.split(' ')[0].toString(),
      "lastName": signUpValues.firstname!.split(' ').length == 1
          ? signUpValues.firstname!.split(' ')[0]
          : signUpValues.firstname!.split(' ')[1],
      "emailId": signUpValues.email.toString(),
      "phoneNumber": signUpValues.number.toString(),
      "countryCode": "+61",
      "password": signUpValues.password,
      "deviceData": await plugin.info
    });
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User Registered'),
        ),
      );
      return Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SignupTextField(
            label: 'First Name',
            hint: 'John',
            action: TextInputAction.next,
            onSaved: (value) {
              signUpValues.firstname = value;
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(lastname);
            },
            type: TextInputType.text,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the first name';
              }
              return null;
            },
          ),
          SignupTextField(
            label: 'Last Name',
            hint: 'Doe',
            action: TextInputAction.next,
            onSaved: (value) {
              signUpValues.lastname = value;
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(email);
            },
            type: TextInputType.text,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the first name';
              }
              return null;
            },
          ),
          SignupTextField(
            focusNode: email,
            label: 'Email',
            hint: 'johndoe@example.com',
            action: TextInputAction.next,
            type: TextInputType.text,
            onSaved: (value) {
              signUpValues.email = value;
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(password);
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the email';
              }
              Pattern emailPattern =
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regex = RegExp(emailPattern as String);
              if (!regex.hasMatch(value)) return 'Enter Valid Email';
              return null;
            },
          ),
          SignupTextField(
            focusNode: password,
            label: 'Password',
            hint: 'secretpassword',
            isPassword: true,
            action: TextInputAction.next,
            type: TextInputType.text,
            onSaved: (value) {
              signUpValues.password = value;
            },
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(cpassword);
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the password';
              }
              return null;
            },
          ),
          SignupTextField(
            focusNode: cpassword,
            label: 'Confirm Password',
            hint: 'secretpassword',
            isPassword: true,
            action: TextInputAction.next,
            type: TextInputType.text,
            onSubmit: (_) {
              FocusScope.of(context).requestFocus(number);
            },
            validator: (value) {
              if (value != signUpValues.password) {
                return 'Passwords don\'t match';
              }
              return null;
            },
          ),
          SignupTextField(
            focusNode: number,
            label: 'Phone Number',
            hint: '412345678',
            action: TextInputAction.done,
            type: TextInputType.number,
            onSaved: (value) {
              signUpValues.number = value;
            },
            onSubmit: (_) {},
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the phone number';
              }
              return null;
            },
          ),
          _button(() async {
            if (_signUpFormKey.currentState == null) {
              debugPrint('emptyformKey');
            } else if (_signUpFormKey.currentState!.validate()) {
              _signUpFormKey.currentState!.save();
              if (Constants.amplifyEnabled) {
                _amplifyRegister(context);
              } else {
                _regularRegister(context);
              }
            }
          }, 'SignUp'),
        ],
      ),
    );
  }
}
