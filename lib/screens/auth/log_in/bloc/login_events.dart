abstract class LoginEvents {
  const LoginEvents();
}

class EmailEvent extends LoginEvents {
  final String email;

 const EmailEvent({required this.email});
}

class PasswordEvent extends LoginEvents {
  final String password;

  const PasswordEvent({required this.password});
}

