String? validateEmailStructure(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  // Simple email validation
  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validatePasswordStructure(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your password";
  }
  // Perform custom password validation here
  if (value.length < 8) {
    return "Password must be at least 8 characters";
  }
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return "Password must contain at least one uppercase letter";
  }
  if (!value.contains(RegExp(r'[a-z]'))) {
    return "Password must contain at least one lowercase letter";
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return "Password must contain at least one number";
  }
  if (!value.contains(RegExp(r'[!@#\$%^&*()<>?/|}{~:]'))) {
    return "Password must contain at least one special character";
  }

  return null;
}
