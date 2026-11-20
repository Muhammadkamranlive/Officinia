// utils.dart
/// Obfuscates a Pakistani mobile number in the format '+923214956656' to '+9232149****6'.
/// Returns an empty string if the input format is incorrect.
///
/// Example:
/// Input: '+923214956656'
/// Output: '+9232149****6'
String obfuscatePhoneNumber(String phoneNumber) {
  // Regular expression to match '+92' followed by exactly 10 digits
  final RegExp phoneRegExp = RegExp(r'^\+92\d{10}$');

  // Check if the input matches the required format
  if (!phoneRegExp.hasMatch(phoneNumber)) {
    return ''; // Return empty string if format is invalid
  }

  // Keep the first 8 characters: '+9232149'
  String prefix = phoneNumber.substring(0, 8);

  // Replace the next 4 digits with asterisks: '****'
  String obfuscatedMiddle = '****';

  // Keep the last character
  String suffix = phoneNumber.substring(12);

  // Combine the parts to form the obfuscated number
  String obfuscatedNumber = '$prefix$obfuscatedMiddle$suffix';

  return obfuscatedNumber;
}

/// Obfuscates an email address by keeping the first and last characters of the local part
/// and obfuscating the middle with asterisks. If the input is invalid, it returns an empty string.
///
/// Example:
/// Input: 'example@example.com'
/// Output: 'e*****e@example.com'
///
/// Input: 'a@example.com' (local part is too short)
/// Output: 'a*@example.com'
String obfuscateEmail(String email) {
  // Regular expression to validate a basic email address format
  final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  // Validate the email format
  if (!emailRegExp.hasMatch(email)) {
    return ''; // Return empty string if the format is invalid
  }

  // Split the email into local and domain parts
  int atIndex = email.indexOf('@');
  String localPart = email.substring(0, atIndex);
  String domainPart = email.substring(atIndex);

  // Obfuscate the local part
  if (localPart.length <= 2) {
    // If the local part is too short, partially obfuscate
    return '${localPart[0]}*${domainPart}';
  } else {
    // Keep the first and last characters and obfuscate the middle
    String firstChar = localPart[0];
    String lastChar = localPart[localPart.length - 1];
    String obfuscatedMiddle = '*' * (localPart.length - 2);
    return '$firstChar$obfuscatedMiddle$lastChar$domainPart';
  }
}

String obfuscateSensitiveData(String input) {
  if (_isMobileNumber(input)) {
    return _obfuscateMobileNumber(input);
  } else if (_isEmail(input)) {
    return _obfuscateEmail(input);
  }
  return input; // Return as-is if it doesn't match mobile or email
}

bool _isMobileNumber(String input) {
  return RegExp(r'^\d{11}$').hasMatch(input); // Matches exactly 11 digits
}

bool _isEmail(String input) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(input); // Basic email regex
}

String _obfuscateMobileNumber(String mobileNumber) {
  return mobileNumber.substring(0, 4) + // Keep first 4 digits
      '*****' + // Replace middle 5 digits with asterisks
      mobileNumber.substring(9); // Keep last 2 digits
}

String _obfuscateEmail(String email) {
  int atIndex = email.indexOf('@');
  if (atIndex <= 1) {
    // If the local part is too short, return partially obfuscated
    return '*' * atIndex + email.substring(atIndex);
  }

  String localPart = email.substring(0, atIndex);
  String domainPart = email.substring(atIndex);

  int visibleChars =
      (localPart.length / 3).floor(); // Show one-third of local part
  return localPart.substring(0, visibleChars) + // First visible part
      '*' * (localPart.length - (2 * visibleChars)) + // Middle obfuscated
      localPart
          .substring(localPart.length - visibleChars) + // Last visible part
      domainPart; // Add domain
}
