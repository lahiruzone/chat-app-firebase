import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

enum LoginState { login, signUp }

class _LoginScreenState extends State<LoginScreen> {
  LoginState _loginState = LoginState.login;

  final _loginFormKry = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  String _name, _email, _password;

  _buildLoginForm() {
    return Form(
      key: _loginFormKry,
      child: Column(
        children: <Widget>[
          _buildEmailTF(),
          _buildPasswordTF(),
        ],
      ),
    );
  }

  _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: <Widget>[
          _buildNameTF(),
          _buildEmailTF(),
          _buildPasswordTF(),
        ],
      ),
    );
  }

  _buildEmailTF() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Email',
        ),
        validator: (input) =>
            !input.contains('@') ? 'Please enter a valied email' : null,
        onSaved: (input) => _email = input,
      ),
    );
  }

  _buildPasswordTF() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Password',
        ),
        validator: (input) =>
            input.length < 6 ? 'Must be atleast 6 charactors' : null,
        onSaved: (input) => _password = input,
        obscureText: true,
      ),
    );
  }

  _buildNameTF() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Name',
        ),
        validator: (input) =>
            input.length == 0 ? 'Name can not be emply' : null,
        onSaved: (input) => _name = input,
      ),
    );
  }

  _submit() async {
    final authService = Provider.of<AuthService>(context,
        listen: false); //listen: false => widgets not rerender
    try {
      if (_loginState == LoginState.login &&
          _loginFormKry.currentState.validate()) {
        _loginFormKry.currentState.save();
        await authService.login(_email, _password);
      } else if (_loginState == LoginState.signUp &&
          _signupFormKey.currentState.validate()) {
        _signupFormKey.currentState.save();
        await authService.signup(_name, _email, _password);
      }
    } catch (err) {
      _showErrorDailog(err.message);
    }
  }

  _showErrorDailog(String errorMessage) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context), child: Text('Ok'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Welcome!",
              style: TextStyle(fontSize: 40.0),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: 150.0,
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      color: _loginState == LoginState.login
                          ? Colors.blue
                          : Colors.grey[300],
                      onPressed: () =>
                          setState(() => _loginState = LoginState.login),
                      child: Text("Login",
                          style: TextStyle(
                              fontSize: 20.0,
                              color: _loginState == LoginState.login
                                  ? Colors.white
                                  : Colors.blue))),
                ),
                SizedBox(width: 40.0),
                Container(
                  width: 150.0,
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      color: _loginState == LoginState.signUp
                          ? Colors.blue
                          : Colors.grey[300],
                      onPressed: () =>
                          setState(() => _loginState = LoginState.signUp),
                      child: Text("Sign up",
                          style: TextStyle(
                              fontSize: 20.0,
                              color: _loginState == LoginState.signUp
                                  ? Colors.white
                                  : Colors.blue))),
                ),
              ],
            ),
            _loginState == LoginState.login
                ? _buildLoginForm()
                : _buildSignupForm(),
            const SizedBox(
              height: 20.0,
            ),
            Container(
              width: 180.0,
              child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.blue,
                  onPressed: _submit,
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
