import 'package:book_isbn_scanner/models/BookModel.dart';
import 'package:flutter/material.dart';

class BookDetailsPage extends StatefulWidget {
  final BookModel bookModel;
  final String isbn;
  const BookDetailsPage({Key? key, required this.bookModel, required this.isbn})
      : super(key: key);

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    TextStyle textStyle2 =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Detected Number:",
                    style: textStyle,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.isbn,
                    style: textStyle2,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    "Book Title:",
                    style: textStyle,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      widget.bookModel.title,
                      style: textStyle2,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    "Author:",
                    style: textStyle,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      widget.bookModel.author,
                      style: textStyle2,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Description:",
                style: textStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.bookModel.description,
                style: textStyle2,
              ),
              const SizedBox(
                height: 40,
              ),
              Center(
                child: Image.network(
                  widget.bookModel.imagePreview,
                  height: 400,
                  width: MediaQuery.of(context).size.width / 1.3,
                  fit: BoxFit.fill,
                ),
              )
            ],
          ),
        ),
      )),
      appBar: AppBar(
        title: const Text("RESULT"),
        centerTitle: true,
      ),
    );
  }
}
