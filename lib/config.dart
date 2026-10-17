import 'dart:io' show Platform;

// Change this to your PC's Wi-Fi IP (run: hostname -I)
const String _lanHost = '192.168.141.93';

String get apiBaseUrl {
  if (Platform.isLinux) return 'http://127.0.0.1:8000/api';   // desktop on the same PC
  if (Platform.isAndroid) return 'http://$_lanHost:8000/api'; // real phone
  return 'http://127.0.0.1:8000/api';                         // iOS simulator, others
}
