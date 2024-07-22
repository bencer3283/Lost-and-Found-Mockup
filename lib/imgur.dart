import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'keys.dart';

Future<String> uploadImageToImgur(XFile image) async {
  final imageBytes = await image.readAsBytes();

  List<int> jpegBytes = await FlutterImageCompress.compressWithList(imageBytes,
      format: CompressFormat.jpeg, quality: 100);

  // Convert the image bytes to base64
  String base64Image = base64Encode(jpegBytes);

  var headers = {'Authorization': 'Client-ID ${imgurId}'};
  var request =
      http.MultipartRequest('POST', Uri.parse('https://api.imgur.com/3/image'));
  request.fields.addAll({
    'image': base64Image,
    'type': 'base64',
    'title': 'Simple upload',
    'description': 'This is a simple image upload in Imgur'
  });

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  var result = '';
  if (response.statusCode == 200) {
    result = await response.stream.bytesToString();
    result = jsonDecode(result)['data']['link'];
  } else {
    result = response.reasonPhrase!;
  }

  //print(result);
  return result;
}
