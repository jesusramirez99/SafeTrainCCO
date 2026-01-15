import 'dart:js_interop';

@JS('env')
external JSObject get _env;

extension EnvJS on JSObject{
  external String get BASE_URL;
  external String get BASE_URL1;
}

class Enviroment {
  static String get baseUrl => _env.BASE_URL;
  static String get baseUrlDev => _env.BASE_URL1;
}