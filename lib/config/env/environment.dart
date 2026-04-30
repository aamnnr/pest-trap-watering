enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static Environment currentEnvironment = Environment.development;

  static String get appName {
    switch (currentEnvironment) {
      case Environment.development:
        return 'PestTrap (Dev)';
      case Environment.staging:
        return 'PestTrap (Staging)';
      case Environment.production:
        return 'PestTrap';
    }
  }

  static String get mqttBroker {
    switch (currentEnvironment) {
      case Environment.development:
        return 'broker.hivemq.com';
      case Environment.staging:
        return 'test.mosquitto.org';
      case Environment.production:
        return 'broker.hivemq.com';
    }
  }

  static int get mqttPort {
    switch (currentEnvironment) {
      case Environment.development:
        return 1883;
      case Environment.staging:
        return 1883;
      case Environment.production:
        return 1883;
    }
  }

  static Duration get connectionTimeout {
    switch (currentEnvironment) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 30);
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }

  static Duration get telemetryInterval => const Duration(minutes: 10);
}

// Export constants for easier access
const String mqttBroker = 'broker.hivemq.com';
const int mqttPort = 1883;
const Duration connectionTimeout = Duration(seconds: 30);
