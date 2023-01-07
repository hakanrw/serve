class User {
  User(this.username, this.email);

  String username;
  String email;

  Map<String, dynamic> toJson() => {
        'name': username,
        'email': email,
      };
}