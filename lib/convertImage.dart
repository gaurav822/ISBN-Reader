// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as im;

Uint8List convertToUnit8(File picture) {
  List<int> imageBase64 = picture.readAsBytesSync();
  String imageAsString = base64Encode(imageBase64);
  Uint8List uint8list = base64.decode(imageAsString);
  return uint8list;
}

Uint8List imageToByteListFloat32(im.Image image, int inputSize) {
  var convertedBytes = Float32List(inputSize * inputSize);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(j, i);
      buffer[pixelIndex++] =
          (im.getRed(pixel) + im.getGreen(pixel) + im.getBlue(pixel)) /
              3 /
              255.0;
    }
  }
  return convertedBytes.buffer.asUint8List();
}
