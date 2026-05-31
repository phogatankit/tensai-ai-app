class AIGeneratedModel {
  String? id;
  String? model;
  List<Output>? output;

  AIGeneratedModel({this.id, this.model, this.output});

  AIGeneratedModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    model = json['model'];
    if (json['output'] != null) {
      output = <Output>[];
      json['output'].forEach((v) {
        output!.add(Output.fromJson(v));
      });
    }
  }
}

class Output {
  String? role;
  List<Content>? content;

  Output({this.role, this.content});

  Output.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    if (json['content'] != null) {
      content = <Content>[];
      json['content'].forEach((v) {
        content!.add(Content.fromJson(v));
      });
    }
  }
}

class Content {
  String? text;

  Content({this.text});

  Content.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }
}