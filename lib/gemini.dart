import 'package:camera/camera.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'keys.dart';

Future<String> identifyWithGemini(XFile image) async {
  final imageBytes = await image.readAsBytes();

  final jpegBytes = await FlutterImageCompress.compressWithList(imageBytes,
      format: CompressFormat.jpeg, quality: 100);

  final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: geminiKey);

  final payload = [
    Content.multi([
      TextPart(
          'I am asking you to identify the object in an image. The object is found in a public transportation system. The information you gave me of the object will be used to index the object in a lost&found database. Please use language that is most likely used by the owner of the object to the search this item in the database.Describe the object in the image. Respond with a json object containing the following items:\n1. object: a general description of what is the object in the image. do not use any adjective here.\n2. description: a list of three descriptions that closely describe the object.\n3. color: a list of two colors that most accurately describe the object in the image. 輸出用繁體中文'),
      DataPart('image/jpeg', jpegBytes)
    ])
  ];

  final response = await model.generateContent(payload);

  print(response.text);
  final response_text = response.text!.substring(7, response.text!.length - 3);
  print(response_text);

  return response_text;
}
