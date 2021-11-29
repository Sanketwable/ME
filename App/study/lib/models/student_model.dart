class Student {
  String firstName = "";
  String lastName = "";
  String profileUrl = "";

  Map toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'profile_url': profileUrl,
      };
  Student(this.firstName, this.lastName, this.profileUrl);
  factory Student.fromJson(dynamic json) {
    return Student(
      json['first_name'] as String,
      json['last_name'] as String,
      json['profile_url'] as String,
    );
  }
}