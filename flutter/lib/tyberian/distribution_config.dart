class TyberianDistribution {
  static const quickSupportMode =
      bool.fromEnvironment('QUICK_SUPPORT_MODE', defaultValue: false);
  static const productName = String.fromEnvironment('PRODUCT_NAME',
      defaultValue: 'Tyberian Remote Support');
  static const companyName =
      String.fromEnvironment('COMPANY_NAME', defaultValue: 'Tyberian');
  static const supportUrl = String.fromEnvironment('SUPPORT_URL',
      defaultValue: 'https://remote.tyberian.com');
  static const supportEmail =
      String.fromEnvironment('SUPPORT_EMAIL', defaultValue: '');
  static const sourceUrl = String.fromEnvironment('SOURCE_CODE_URL',
      defaultValue: 'https://github.com/rustdesk/rustdesk');
  static const idServer = String.fromEnvironment('ID_SERVER',
      defaultValue: 'remote.tyberian.com');
  static const relayServer =
      String.fromEnvironment('RELAY_SERVER', defaultValue: '');
  static const serverPublicKey =
      String.fromEnvironment('SERVER_PUBLIC_KEY', defaultValue: '');

  static const _forbiddenSecret = String.fromEnvironment('SERVER_PRIVATE_KEY');

  static void validate() {
    if (_forbiddenSecret.isNotEmpty) {
      throw StateError('SERVER_PRIVATE_KEY must never be embedded in a client');
    }
    if (quickSupportMode && idServer.trim().isEmpty) {
      throw StateError('ID_SERVER is required in QuickSupport mode');
    }
  }
}
