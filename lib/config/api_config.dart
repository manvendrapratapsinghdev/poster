class ApiConfig {
  static const backedBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://api.postershaala.com',
  );
}
