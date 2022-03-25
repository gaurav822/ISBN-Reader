import 'dart:convert';
import 'dart:developer';
import 'package:book_isbn_scanner/models/BookModel.dart';
import 'package:http/http.dart';

class ApiCall {
  static Future<BookModel> fetchBookDetails(
      {required String isbnNumber}) async {
    String url =
        "https://www.googleapis.com/books/v1/volumes?q=isbn:$isbnNumber";

    try {
      Response response = await get(Uri.parse(url));
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse["totalItems"] == 0) {
        return BookModel(
            title: "Not found",
            author: "Not found",
            description: "Not found",
            imagePreview:
                "https://books.google.com.np/googlebooks/images/no_cover_thumb.gif");
      } else {
        Map<String, dynamic> defaultImages = {
          "smallThumbnail":
              "https://books.google.com.np/googlebooks/images/no_cover_thumb.gif",
          "thumbnail":
              "https://books.google.com.np/googlebooks/images/no_cover_thumb.gif"
        };

        List<dynamic> items = jsonResponse["items"];
        Map<String, dynamic> first = items[0];
        Map<String, dynamic> volumeInfo = first["volumeInfo"];
        Map<String, dynamic> imageLinks =
            volumeInfo["imageLinks"] ?? defaultImages;
        String title = volumeInfo["title"] ?? "N/A";
        List<dynamic> authors = volumeInfo["authors"] ?? ["N/A"];
        String description = volumeInfo["description"] ?? "N/A";
        String imagePreview = imageLinks["smallThumbnail"];

        String allAuthor = "";
        for (int i = 0; i < authors.length; i++) {
          allAuthor = allAuthor + authors[i] + ",";
        }
        return BookModel(
          imagePreview: imagePreview,
          title: title,
          author: allAuthor,
          description: description,
        );
      }
    } catch (e) {
      log(e.toString());
      return BookModel(
          title: "204",
          author: "204",
          description: "204",
          imagePreview:
              "https://books.google.com.np/googlebooks/images/no_cover_thumb.gif");
    }
  }
}
