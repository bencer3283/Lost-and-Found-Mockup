import 'dart:convert';

import 'package:http/http.dart' as http;
import 'keys.dart';

Future<String> uploadImageToImgur(String base64Image) async {
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

  print(result);
  return result;
}
