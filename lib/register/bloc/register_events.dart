abstract class RegisterEvents {
  const RegisterEvents();
}

class UserNameEvent extends RegisterEvents {
  final String userName;

  UserNameEvent(this.userName);
}

class EmailEvent extends RegisterEvents {
  final String email;

  EmailEvent(this.email);
}

class PasswordEvent extends RegisterEvents {
  final String password;

  PasswordEvent(this.password);
}

class ConfirmPasswordEvent extends RegisterEvents {
  final String confirmPassword;

  ConfirmPasswordEvent(this.confirmPassword);
}