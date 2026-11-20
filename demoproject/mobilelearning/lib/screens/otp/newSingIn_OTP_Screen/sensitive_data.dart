// utils.dart

/// Obfuscates sensitive data such as mobile numbers and emails.
///
/// - For mobile numbers starting with '+92' followed by 10 digits, it obfuscates the middle 5 digits.
/// - For emails, it obfuscates the middle part of the local section.
/// - Returns the input as-is if it doesn't match mobile or email patterns.
String obfuscateSensitiveData(String input) {
  if (_isMobileNumber(input)) {
    return _obfuscateMobileNumber(input);
  } else if (_isEmail(input)) {
    return _obfuscateEmail(input);
  }
  return input; // Return as-is if it doesn't match mobile or email
}

/// Checks if the input string is a mobile number starting with '+92' followed by exactly 10 digits.
///
/// Example of valid input: '+9232404454808'
bool _isMobileNumber(String input) {
  return RegExp(r'^\+92\d{10}$')
      .hasMatch(input); // Matches '+92' followed by exactly 10 digits
}

/// Checks if the input string is a valid email address using a basic regex pattern.
bool _isEmail(String input) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(input); // Basic email regex
}

/// Obfuscates a mobile number by keeping the first 5 characters ('+9232'), replacing the next 5 digits with asterisks,
/// and keeping the last 3 digits.
///
/// Example:
/// - Input: '+9232404454808'
/// - Output: '+9232*****808'
String _obfuscateMobileNumber(String mobileNumber) {
  // Validate the mobile number format
  if (mobileNumber.length != 13 || !mobileNumber.startsWith('+92')) {
    // Handle invalid format as needed. Here, we return the input unmodified.
    return mobileNumber;
  }

  // Keep the first 5 characters ('+9232')
  String prefix = mobileNumber.substring(0, 5);

  // Replace the next 5 digits with asterisks
  String obfuscatedMiddle = '*****';

  // Keep the last 3 digits
  String suffix = mobileNumber.substring(10);

  return '$prefix$obfuscatedMiddle$suffix';
}

/// Obfuscates an email address by keeping the first and last third of the local part and replacing the middle with asterisks.
///
/// Example:
/// - Input: 'example@example.com'
/// - Output: 'ex***le@example.com'
String _obfuscateEmail(String email) {
  int atIndex = email.indexOf('@');

  // If the local part is too short, partially obfuscate
  if (atIndex <= 1) {
    return '*' * atIndex + email.substring(atIndex);
  }

  String localPart = email.substring(0, atIndex);
  String domainPart = email.substring(atIndex);

  int visibleChars =
      (localPart.length / 3).floor(); // Show one-third of local part

  // Handle cases where localPart length is not perfectly divisible by 3
  if (visibleChars == 0) visibleChars = 1;

  String firstVisible = localPart.substring(0, visibleChars);
  String obfuscatedMiddle = '*' * (localPart.length - (2 * visibleChars));
  String lastVisible = localPart.substring(localPart.length - visibleChars);

  return '$firstVisible$obfuscatedMiddle$lastVisible$domainPart';
}
