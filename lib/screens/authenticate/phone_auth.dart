import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/foundation.dart' show ChangeNotifier, VoidCallback;
import 'package:flutter/widgets.dart' show BuildContext, TextEditingController;
import 'package:shared_preferences/shared_preferences.dart';


class FireBase {
  static FirebaseAuth.FirebaseAuth auth = FirebaseAuth.FirebaseAuth.instance;

  static instantiate(){

  }
}

enum PhoneAuthState {
  Started,
  CodeSent,
  CodeResent,
  Verified,
  Failed,
  Error,
  AutoRetrievalTimeOut
}

class PhoneAuthDataProvider with ChangeNotifier {
  VoidCallback onStarted,
      onCodeSent,
      onCodeResent,
      //onVerified,
      onFailed,
      onError,
      onAutoRetrievalTimeout;
  void Function(FirebaseAuth.User user, String phone) onVerified;

  bool _loading = false;

  final TextEditingController _phoneNumberController = TextEditingController();

  PhoneAuthState _status;
  var _authCredential;
  String _actualCode;
  String _phone, _message;

  setMethods(
      {VoidCallback onStarted,
        VoidCallback onCodeSent,
        VoidCallback onCodeResent,
        //VoidCallback onVerified,
        VoidCallback onFailed,
        VoidCallback onError,
        VoidCallback onAutoRetrievalTimeout,
        void Function(FirebaseAuth.User user, String phone) onVerified }) {
    this.onStarted = onStarted;
    this.onCodeSent = onCodeSent;
    this.onCodeResent = onCodeResent;
    this.onVerified = onVerified;
    this.onFailed = onFailed;
    this.onError = onError;
    this.onAutoRetrievalTimeout = onAutoRetrievalTimeout;

  }

  Future<bool> instantiate(
      {String dialCode,
        VoidCallback onStarted,
        VoidCallback onCodeSent,
        VoidCallback onCodeResent,
        //VoidCallback onVerified,
        VoidCallback onFailed,
        VoidCallback onError,
        VoidCallback onAutoRetrievalTimeout,
        void Function(FirebaseAuth.User user, String phone) onVerified}) async {
    this.onStarted = onStarted;
    this.onCodeSent = onCodeSent;
    this.onCodeResent = onCodeResent;
    this.onVerified = onVerified;
    this.onFailed = onFailed;
    this.onError = onError;
    this.onAutoRetrievalTimeout = onAutoRetrievalTimeout;
    //this.onABC = onABC;

    if (phoneNumberController.text.length < 10) {
      return false;
    }
    phone = dialCode + phoneNumberController.text;
    print(phone);
    _startAuth();
    return true;
  }

  _startAuth() {
    final FirebaseAuth.PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      actualCode = verificationId;
      _addStatusMessage("\nEnter the code sent to " + phone);
      _addStatus(PhoneAuthState.CodeSent);
      if (onCodeSent != null) onCodeSent();
    };

    final FirebaseAuth.PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      actualCode = verificationId;
      _addStatusMessage("\nAuto retrieval time out");
      _addStatus(PhoneAuthState.AutoRetrievalTimeOut);
      if (onAutoRetrievalTimeout != null) onAutoRetrievalTimeout();
    };

    final FirebaseAuth.PhoneVerificationFailed verificationFailed =
        (FirebaseAuth.FirebaseAuthException authException) {
      _addStatusMessage('${authException.message}');
      _addStatus(PhoneAuthState.Failed);
      if (onFailed != null) onFailed();
      if (authException.message.contains('not authorized'))
        _addStatusMessage('App not authroized');
      else if (authException.message.contains('Network'))
        _addStatusMessage(
            'Please check your internet connection and try again');
      else
        _addStatusMessage('Something has gone wrong, please try later ' +
            authException.message);
    };

    final FirebaseAuth.PhoneVerificationCompleted verificationCompleted =
        (FirebaseAuth.AuthCredential auth) {
      _addStatusMessage('Auto retrieving verification code');

      FireBase.auth.signInWithCredential(auth).then((FirebaseAuth.UserCredential value) {
        if (value.user != null) {
          _addStatusMessage('Authentication successful');
          _addStatus(PhoneAuthState.Verified);
          if (onVerified != null) onVerified(value.user , phone);
        } else {
          if (onFailed != null) onFailed();
          _addStatus(PhoneAuthState.Failed);
          _addStatusMessage('Invalid code/invalid authentication');
        }
      }).catchError((error) {
        if (onError != null) onError();
        _addStatus(PhoneAuthState.Error);
        _addStatusMessage('Something has gone wrong, please try later $error');
      });
    };

    _addStatusMessage('Phone auth started');
    FireBase.auth
        .verifyPhoneNumber(
        phoneNumber: phone.toString(),
        timeout: Duration(seconds: 60 * 2),  // OTP TIMEOUT INCREASED TO 2 MINUTES
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
        .then((value) {
      if (onCodeSent != null) onCodeSent();
      _addStatus(PhoneAuthState.CodeSent);
      _addStatusMessage('Code sent');
    }).catchError((error) {
      if (onError != null) onError();
      _addStatus(PhoneAuthState.Error);
      _addStatusMessage(error.toString());
    });
  }

  void verifyOTPAndLogin({String smsCode, BuildContext context}) async {
    _authCredential = FirebaseAuth.PhoneAuthProvider.credential(
        verificationId: actualCode, smsCode: smsCode);

    FireBase.auth
        .signInWithCredential(_authCredential)
        .then((FirebaseAuth.UserCredential result) async {
      _addStatusMessage(getTranslated(context, "auth_success_key"));
      _addStatus(PhoneAuthState.Verified);
      if (onVerified != null) onVerified(result.user, phone);
    }).catchError((error) {
      if (onError != null) onError();
      _addStatus(PhoneAuthState.Error);
      _addStatusMessage(
          getTranslated(context, "try_later_error_key") + ' $error');
    });
  }

  _addStatus(PhoneAuthState state) {
    status = state;
  }

  void _addStatusMessage(String s) {
    message = s;
  }

  get authCredential => _authCredential;

  set authCredential(value) {
    _authCredential = value;
    notifyListeners();
  }

  get actualCode => _actualCode;

  set actualCode(String value) {
    _actualCode = value;
    notifyListeners();
  }

  get phone => _phone;

  set phone(String value) {
    _phone = value;
    notifyListeners();
  }

  get message => _message;

  set message(String value) {
    _message = value;
    notifyListeners();
  }

  PhoneAuthState get status => _status;

  set status(PhoneAuthState value) {
    _status = value;
    notifyListeners();
  }

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  User _userFromFirebaseUser(FirebaseAuth.User user) {
    return user != null ? User(uid: user.uid ) : null;
  }

  Stream<User> get user {
    return FireBase.auth.authStateChanges()
    //.map((FirebaseUser user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  TextEditingController get phoneNumberController => _phoneNumberController;

  // sign out
  Future signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('PhoneNo');
      prefs.remove('RegisterState');
      prefs.commit();
      return await FireBase.auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}