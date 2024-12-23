String? validateEmailStructure(String? value) {
  if (value == null ||
      value.trim().isEmpty ||
      !value.contains('@') ||
      !value.contains('.')) {
    return "Please enter a valid email address";
  }
  return null;
}

String? validatePasswordStructure(String? value) {
  if (value == null || value.isEmpty) {
    return "Password is required";
  }
  // Perform custom password validation here
  if (value.length < 8) {
    return "Password must be at least 8 characters long";
  }
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return "Password must contain at least one uppercase letter";
  }
  if (!value.contains(RegExp(r'[a-z]'))) {
    return "Password must contain at least one lowercase letter";
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return "Password must contain at least one numeric character";
  }
  if (!value.contains(RegExp(r'[!@#\$%^&*()<>?/|}{~:]'))) {
    return "Password must contain at least one special character";
  }

  return null;
}
