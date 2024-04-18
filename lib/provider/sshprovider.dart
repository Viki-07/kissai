import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';

//provider class for state management
class SSHClientProvider extends ChangeNotifier {
  String _ip = '192.168.1.7';
  String _username = 'lg';
  String _password = '12';
  int _port = 2222;
  int _rigs = 3;
  bool _isConnected = false;
  SSHClient? _client;

  String get ip => _ip;
  String get username => _username;
  String get password => _password;
  int get port => _port;
  int get rigs => _rigs;
  bool get isConnected => _isConnected;
  SSHClient? get client => _client;

  set ip(String value) {
    _ip = value;
    notifyListeners();
  }

  set username(String value) {
    _username = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  set port(int value) {
    _port = value;
    notifyListeners();
  }

  set rigs(int value) {
    _rigs = value;
    notifyListeners();
  }

  set isConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  set client(SSHClient? value) {
    _client = value;
    notifyListeners();
  }
}
