import 'package:pocketflow/core/enums/environment.dart';

import 'dev_env.dart';
import 'prod_env.dart';
import 'env.dart';

class EnvConfig {
  static late Env _env;

  static Future<void> init({required Environment environment}) async {
    switch (environment) {
      case Environment.prod:
        _env = ProdEnv();
        break;
      case Environment.dev:
        _env = DevEnv();
    }
  }

  static Env get instance => _env;
}
