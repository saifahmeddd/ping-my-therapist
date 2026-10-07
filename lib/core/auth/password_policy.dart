/// Returns a user-facing error when a new account password misses a requirement.
String? validateNewPassword(String password) {
  const commonTerms = ['password', 'qwerty', 'welcome', 'letmein', 'admin'];
  if (password.length < 8 ||
      !RegExp(r'[A-Z]').hasMatch(password) ||
      !RegExp(r'[a-z]').hasMatch(password) ||
      !RegExp(r'[0-9]').hasMatch(password) ||
      !RegExp(r'[^A-Za-z0-9\s]').hasMatch(password) ||
      RegExp(r'\s').hasMatch(password) ||
      commonTerms.any(password.toLowerCase().contains)) {
    return 'Use 8+ characters with uppercase, lowercase, a number and a symbol, without spaces or common passwords.';
  }
  return null;
}
