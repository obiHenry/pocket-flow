import 'env.dart';

class ProdEnv implements Env {
  @override
  String get baseUrl => 'https://api.pocketflow.com';

  @override
  String get appName => 'PocketFlow';

  @override
  bool get enableLogs => false;

  @override
  String get exchangeUrl => 'https://api.frankfurter.dev/v1';
}
