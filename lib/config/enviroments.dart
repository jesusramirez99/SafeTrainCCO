import 'dart:js' as js;

class Enviroment {

  static String get baseUrl =>
      js.context['env']['BASE_URL'];
}