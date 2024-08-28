import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'keys.dart';
import 'imgur.dart';

Future<String> identifyOdjectWithClaude(XFile image) async {
  final imageBytes = await image.readAsBytes();

  List<int> jpegBytes = await FlutterImageCompress.compressWithList(imageBytes,
      format: CompressFormat.jpeg, quality: 100);

  // Convert the image bytes to base64
  String base64Image = base64Encode(jpegBytes);

  final Map<String, dynamic> requestBody = {
    "model": "claude-3-5-sonnet-20240620",
    "max_tokens": 128,
    "system":
        "I am asking you to identify the object in an image. The object is found in a public transportation system. The information you gave me of the object will be used to index the object in a lost&found database. Please use language that is most likely used by the owner of the object to the search this item in the database.",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text":
                "Describe the object in the image. Respond with a json object containing the following items:\n1. object: a general description of what is the object in the image. do not use any adjective here.\n2. description: a list of three adjectives that closely describe the object.\n3. color: a list of two colors that most accurately describe the object in the image."
          },
          {
            "type": "image",
            "source": {
              "type": "base64",
              "media_type": "image/jpeg",
              "data": base64Image
            }
          }
        ]
      }
    ]
  };
  final response =
      await http.post(Uri.parse("https://api.anthropic.com/v1/messages"),
          headers: {
            'x-api-key': claudeKey,
            "anthropic-version": "2023-06-01",
            'content-type': 'application/json'
          },
          body: jsonEncode(requestBody));
  String result = '';
  if (response.statusCode == 200) {
    // print('Success!');
    result = jsonDecode(response.body)['content'][0]['text'].toString();
    // print(response.body.toString());
  } else {
    result = response.body.toString();
    // print(response.statusCode.toString() + response.body.toString());
  }

  return result;
}
