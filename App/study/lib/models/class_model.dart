class MyClasses {
  int classID;
  String classCode = "";
  int facultyID;
  String classLink = "";
  int year;
  String branch = "";
  String subject = "";
  String imageLink = "";

  Map toJson() => {
        'class_id': classID,
        'class_code': classCode,
        'faculty_id': facultyID,
        'link': classLink,
        'year': year,
        'branch': branch,
        'subject': subject,
        'image_link': imageLink,
      };
  MyClasses(this.classID, this.classCode, this.facultyID, this.classLink,
      this.year, this.branch, this.subject, this.imageLink);

  factory MyClasses.fromJson(dynamic json) {
    return MyClasses(
        json['class_id'] as int,
        json['class_code'] as String,
        json['faculty_id'] as int,
        json['link'] as String,
        json['year'] as int,
        json['branch'] as String,
        json['subject'] as String,
        json['image_link'] as String);
  }
}
