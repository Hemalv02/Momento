class SignUpStates {
  final String name;
  final String userName;
  final String email;
  final DateTime dateOfBirth;
  final String password;
  final String confirmPassword;
  final bool isChecked;

  const SignUpStates({
    required this.name,
    required this.userName,
    required this.email,
    required this.dateOfBirth,
    required this.password,
    required this.confirmPassword,
    required this.isChecked,
  });

  SignUpStates copyWith({
    String? name,
    String? userName,
    String? email,
    DateTime? dateOfBirth,
    String? password,
    String? confirmPassword,
    bool? isChecked,
  }) {
    return SignUpStates(
      name: name ?? this.name,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  // You might want to add a factory constructor for initial state
  factory SignUpStates.initial() {
    return SignUpStates(
      name: '',
      userName: '',
      email: '',
      dateOfBirth: DateTime.now(), // Default to current date
      password: '',
      confirmPassword: '',
      isChecked: false,
    );
  }
}