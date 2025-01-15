abstract class SignUpEvents {
  const SignUpEvents();
}

class UserNameEvent extends SignUpEvents {
  final String userName;

  UserNameEvent(this.userName);
}

class EmailEvent extends SignUpEvents {
  final String email;

  EmailEvent(this.email);
}

class PasswordEvent extends SignUpEvents {
  final String password;

  PasswordEvent(this.password);
}

class ConfirmPasswordEvent extends SignUpEvents {
  final String confirmPassword;

  ConfirmPasswordEvent(this.confirmPassword);
}
