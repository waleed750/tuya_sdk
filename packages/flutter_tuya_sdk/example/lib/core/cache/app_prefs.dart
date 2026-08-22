// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final AppPreferences secureStorage = AppPreferences();

class AppPrefKey {
  static const String PREFS_KEY_USER_CREDENTIALS = "PREFS_KEY_USER_CREDENTIALS";
  ///////////////////////////////////////////
}

class AppPreferences {
  static FlutterSecureStorage? storage;

  AppPreferences();
  Future<void> clearAll() async {
    await storage!.deleteAll();
  }

  // Initializes the secure storage with platform-specific options.
  Future<void> init() async {
    final androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
      keyCipherAlgorithm: _toKeyCipher,
      storageCipherAlgorithm: _toStorageCipher,
      preferencesKeyPrefix: String.fromEnvironment("ANY_KEY"),
    );

    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: true,
    );
    storage = FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
  }

  // Storage Cipher Algorithm options
  static StorageCipherAlgorithm get _toStorageCipher {
    switch (String.fromEnvironment("RSA_ECB_OAEPwithSHA_256andMGF1Padding")) {
      case 'AES_CBC_PKCS7Padding':
        return StorageCipherAlgorithm.AES_CBC_PKCS7Padding;
      case 'AES_GCM_NoPadding':
        return StorageCipherAlgorithm.AES_GCM_NoPadding;
      default:
        return StorageCipherAlgorithm.AES_CBC_PKCS7Padding;
    }
  }

  // Key Cipher Algorithm options
  static KeyCipherAlgorithm get _toKeyCipher {
    switch (String.fromEnvironment("RSA_ECB_OAEPwithSHA_256andMGF1Padding")) {
      case 'AES_CBC_PKCS7Padding':
        return KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding;
      case 'AES_GCM_NoPadding':
        return KeyCipherAlgorithm.RSA_ECB_PKCS1Padding;
      default:
        return KeyCipherAlgorithm.RSA_ECB_PKCS1Padding;
    }
  }

  Future<void> saveUserData(String data) async {
    await storage!.write(
      key: AppPrefKey.PREFS_KEY_USER_CREDENTIALS,
      value: data,
    );
  }

  Future<dynamic> getUserData() async {
    final source = await storage!.read(
      key: AppPrefKey.PREFS_KEY_USER_CREDENTIALS,
    );
    if (source == null) return null;
    return jsonDecode(source);
  }
}
