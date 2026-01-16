class ApiConfig {
  static const backedBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://192.168.1.6:8000',
  );
}
