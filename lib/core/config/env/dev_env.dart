import 'env.dart';

class DevEnv implements Env {
  @override
  String get baseUrl => 'https://dev-api.pocketflow.com';

  @override
  String get appName => 'PocketFlow Dev';

  @override
  bool get enableLogs => true;

  @override
  String get exchangeUrl => 'https://api.frankfurter.dev/v1';
}
