class MessageModel {
  String? id;
  String? content;

  MessageModel({
    this.id,
    this.content,
  });

  // Factory method to create a LoginEntity from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? "",
      content: json['content'] ?? "",
    );
  }

  // Method to convert LoginEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
    };
  }
}
