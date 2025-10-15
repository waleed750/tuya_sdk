// Interface for Tuya Auth API
abstract class TuyaAuthApi {
  Future<void> sendVerificationEmail(String email);
  Future<bool> isEmailVerified(String email);
  Future<String> register(String email, String password);
  Future<String> login(String email, String password);
  Future<void> createHome({
    required String name,
    required String timeZoneId,
    required double lat,
    required double lon,
    String? geoName,
  });
}

// Mock implementation for development
class MockTuyaAuthApi implements TuyaAuthApi {
  final Map<String, bool> _verifiedEmails = {};
  final Map<String, String> _registeredUsers = {};
  
  @override
  Future<void> sendVerificationEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate sending verification email
    _verifiedEmails[email] = false;
    
    // Auto-verify after a random delay (for testing purposes)
    Future.delayed(Duration(seconds: 10 + (email.hashCode % 10)), () {
      _verifiedEmails[email] = true;
    });
  }

  @override
  Future<bool> isEmailVerified(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _verifiedEmails[email] ?? false;
  }

  @override
  Future<String> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!(_verifiedEmails[email] ?? false)) {
      throw Exception('Email not verified');
    }
    
    final token = 'token_${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    _registeredUsers[email] = token;
    return token;
  }

  @override
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final token = _registeredUsers[email];
    if (token == null) {
      // For testing, allow login with any credentials if not registered
      final newToken = 'token_${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
      _registeredUsers[email] = newToken;
      return newToken;
    }
    
    return token;
  }

  @override
  Future<void> createHome({
    required String name,
    required String timeZoneId,
    required double lat,
    required double lon,
    String? geoName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock implementation - just simulate success
  }
}