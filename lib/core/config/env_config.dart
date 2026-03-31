enum Env {
  dev('dev'),
  prod('prod');

  const Env(this.value);
  final String value;
}

abstract class EnvConfig {
  static Env get env => _env;

  static late Env _env;
  static late String baseUrl;
  static late String hostUrl;
  static late String envName;

  static void init(Env env) {
    _env = env;

    switch (env) {
      case Env.dev:
        envName = 'Development';
        baseUrl = 'https://hbss.brpconstruction.online/api/v1/';
        hostUrl = 'https://hbss.brpconstruction.online/';
      case Env.prod:
        envName = 'Production';
        baseUrl = 'https://hbss.brpconstruction.online/api/v1/';
        hostUrl = 'https://hbss.brpconstruction.online/';
    }
  }

  static bool get isDev => _env == Env.dev;
  static bool get isProd => _env == Env.prod;
}
