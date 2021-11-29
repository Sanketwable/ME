class MyQuestion {
  String question = "";
  String option1 = "";
  String option2 = "";
  String option3 = "";
  String option4 = "";
  int answer = 0;
  Map toJson() => {
        'question': question,
        'option1': option1,
        'option2': option2,
        'option3': option3,
        'option4': option4,
        'answer': answer,
      };
  MyQuestion(this.question, this.option1, this.option2, this.option3,
      this.option4, this.answer);
  factory MyQuestion.fromJson(dynamic json) {
    return MyQuestion(
        json['question'] as String,
        json['option1'] as String,
        json['option2'] as String,
        json['option3'] as String,
        json['option4'] as String,
        json['answer'] as int);
  }
}