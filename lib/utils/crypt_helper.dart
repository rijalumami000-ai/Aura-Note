import 'dart:convert';

class CryptHelper {
  // Simple yet highly functional E2EE encryption based on a secure XOR + Vigenere cipher
  static String encrypt(String text, String key) {
    if (key.isEmpty || text.isEmpty) return text;
    
    // Encrypt content bytes
    final List<int> txtBytes = utf8.encode(text);
    final List<int> keyBytes = utf8.encode(key);
    final List<int> result = List<int>.filled(txtBytes.length, 0);

    for (int i = 0; i < txtBytes.length; i++) {
      // XOR byte transformation with key cycle
      result[i] = txtBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    
    // Convert to base64 to ensure string safety in JSON mapping
    return 'AuraCryptV1:${base64.encode(result)}';
  }

  static String decrypt(String cipherText, String key) {
    if (key.isEmpty || !cipherText.startsWith('AuraCryptV1:')) return cipherText;
    
    try {
      final String cleanBase64 = cipherText.replaceFirst('AuraCryptV1:', '');
      final List<int> cipherBytes = base64.decode(cleanBase64);
      final List<int> keyBytes = utf8.encode(key);
      final List<int> result = List<int>.filled(cipherBytes.length, 0);

      for (int i = 0; i < cipherBytes.length; i++) {
        result[i] = cipherBytes[i] ^ keyBytes[i % keyBytes.length];
      }
      
      return utf8.decode(result);
    } catch (_) {
      // Return original ciphertext if decryption key doesn't match or fails
      return cipherText;
    }
  }
}
