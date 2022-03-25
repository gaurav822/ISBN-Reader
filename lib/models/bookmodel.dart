import 'dart:convert';

class BookModel {
  BookModel(
      {required this.title,
      required this.author,
      required this.description,
      required this.imagePreview});

  final String title;
  final String author;
  final String description;
  final String imagePreview;

  factory BookModel.fromJson(String str) => BookModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookModel.fromMap(Map<String, dynamic> json) => BookModel(
      title: json["title"],
      author: json["Author"],
      description: json["Description"],
      imagePreview: json["imagePreview"]);

  Map<String, dynamic> toMap() => {
        "title": title,
        "Author": author,
        "Description": description,
        "imagePreview": imagePreview
      };
}
