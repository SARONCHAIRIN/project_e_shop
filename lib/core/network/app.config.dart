enum Environment {
  local,
  ip,
  server,
}

class AppConfig {
  static const Environment environment = Environment.local;

  static String get baseUrl {
    switch (environment) {
      case Environment.local:
        return "http://localhost:8080";

      case Environment.ip:
        return "http://10.1.121.208:8080";

      case Environment.server:
        return "https://e-shop-1-m034.onrender.com";
    }
  }
}