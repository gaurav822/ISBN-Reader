import 'dart:io';
import 'package:book_isbn_scanner/Api/apicall.dart';
import 'package:book_isbn_scanner/bookdetailpage.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'models/BookModel.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController controller;
  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420);
    controller.setFlashMode(FlashMode.off);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";

  TextEditingController isbnController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ISBN Number Scanner"),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: CameraPreview(controller))
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          try {
                            final pickedImage = await controller.takePicture();
                            if (pickedImage != null) {
                              textScanning = true;
                              imageFile = pickedImage;
                              setState(() {});
                              scannedText = "";
                              setState(() {});
                              detectISBNFromBarcode(pickedImage);
                            }
                          } catch (e) {
                            textScanning = false;
                            imageFile = null;
                            scannedText = "Error occured while scanning";
                            setState(() {});
                          }
                        },
                        child: const Text(
                          "Capture",
                          style: TextStyle(fontSize: 18),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                          onPressed: () {
                            openManualisbnDialog();
                          },
                          child: const Text(
                            "Type Code Manually",
                          )),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                  ),
                if (imageFile != null)
                  Image.file(
                    File(imageFile!.path),
                    height: 300,
                    width: 300,
                    fit: BoxFit.fill,
                  ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.grey,
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.gallery);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.image,
                                  size: 30,
                                ),
                                Text(
                                  "Gallery",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  child: Text(
                    scannedText,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            )),
      )),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        detectISBNFromBarcode(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void detectISBNFromBarcode(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final barcodeScan = GoogleMlKit.vision.barcodeScanner();
    final List<Barcode> barcodes = await barcodeScan.processImage(inputImage);
    scannedText = "";
    setState(() {});
    for (Barcode barcode in barcodes) {
      final String displayValue = barcode.value.displayValue.toString();
      scannedText = scannedText + displayValue;
    }

    textScanning = false;
    setState(() {});

    if (scannedText.isEmpty) {
      Fluttertoast.showToast(
          msg: "Isbn Number not detected. Retry again",
          backgroundColor: Colors.red,
          fontSize: 16);
    } else {
      Fluttertoast.showToast(
          msg: "ISBN Number Detected",
          backgroundColor: Colors.green,
          fontSize: 18);

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Text("Please wait..."),
                    CircularProgressIndicator()
                  ],
                ),
              ));

      fetchBookDetails(scannedText);
    }
  }

  Future<void> fetchBookDetails(String isbnNumber) async {
    BookModel bookModel =
        await ApiCall.fetchBookDetails(isbnNumber: isbnNumber);
    Navigator.of(context).pop();
    if (bookModel.author == "204") {
      Fluttertoast.showToast(
          msg: "Exception occured", backgroundColor: Colors.red);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BookDetailsPage(
                bookModel: bookModel,
                isbn: isbnNumber,
              )));
    }
  }

  bool isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void openManualisbnDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    const Text("Type ISBN Code Below",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: isbnController,
                    )
                  ],
                ),
              ),
              actions: [
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      isbnController.clear();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    )),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {
                    if (!isNumeric(isbnController.text)) {
                      Fluttertoast.showToast(
                          msg: "ISBN must be only numbers",
                          backgroundColor: Colors.red);
                      return;
                    } else if (isbnController.text.length == 10 ||
                        isbnController.text.length == 13) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: const [
                                    Text("Please wait..."),
                                    CircularProgressIndicator()
                                  ],
                                ),
                              ));
                      fetchBookDetails(isbnController.text.toString());
                    } else {
                      Fluttertoast.showToast(
                          msg: "ISBN Length must be 10 or 13 digit long",
                          backgroundColor: Colors.red);
                      return;
                    }
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                )
              ],
            ));
  }
}
