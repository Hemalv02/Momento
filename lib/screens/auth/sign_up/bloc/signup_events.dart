abstract class SignUpEvents {}

class NameEvent extends SignUpEvents {
  final String name;
  NameEvent(this.name);
}

class UserNameEvent extends SignUpEvents {
  final String userName;
  UserNameEvent(this.userName);
}

class EmailEvent extends SignUpEvents {
  final String email;
  EmailEvent(this.email);
}

class DateOfBirthEvent extends SignUpEvents {
  final DateTime dateOfBirth;
  DateOfBirthEvent(this.dateOfBirth);
}

class PasswordEvent extends SignUpEvents {
  final String password;
  PasswordEvent(this.password);
}

class ConfirmPasswordEvent extends SignUpEvents {
  final String confirmPassword;
  ConfirmPasswordEvent(this.confirmPassword);
}

class CheckEvent extends SignUpEvents {
  final bool isChecked;
  CheckEvent(this.isChecked);
}