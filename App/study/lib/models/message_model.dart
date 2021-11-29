class Message {
  int messageID = 0;
  int classID = 0;
  int userID = 0;
  String message = "";
  String firstName = "";
  String lastName = "";
  String time = "";

  Map toJson() => {
        'message_id': messageID,
        'class_id': classID,
        'user_id': userID,
        'message': message,
        'first_name': firstName,
        'last_name': lastName,
        'time': time,
      };
  Message(this.messageID, this.classID, this.userID, this.message,
      this.firstName, this.lastName, this.time);

  factory Message.fromJson(dynamic json) {
    return Message(
        json['message_id'] as int,
        json['class_id'] as int,
        json['user_id'] as int,
        json['message'] as String,
        json['first_name'] as String,
        json['last_name'] as String,
        json['time'] as String);
  }
}
