import 'dart:convert';
import 'package:camera/camera.dart';
import 'keys.dart';
import 'package:http/http.dart' as http;
import 'imgur.dart';

const databaseId = '9aeebd9e7243419e88eaebca530df04f';

Future<String> uploadFoundObject(
    Map<String, dynamic> object, String location) async {
  final requestBody = <String, dynamic>{
    "parent": {"type": "database_id", "database_id": databaseId},
    "properties": {
      "ID": {
        "type": "title",
        "title": [
          {
            "type": "text",
            "text": {"content": "${object.hashCode}"}
          }
        ]
      },
      "Colors": {
        "type": "rich_text",
        "rich_text": [
          {
            "type": "text",
            "text": {"content": "${object['color'][0]}, ${object['color'][1]}"}
          }
        ]
      },
      "Object": {
        "type": "select",
        "select": {"name": object['object']}
      },
      "Descriptions": {
        "type": "rich_text",
        "rich_text": [
          {
            "type": "text",
            "text": {
              "content":
                  "${object['description'][0]}, ${object['description'][1]}, ${object['description'][2]}"
            }
          }
        ]
      },
      "Date": {
        "type": "date",
        "date": {
          "start": DateTime.now().toLocal().toIso8601String(),
          "time_zone": "Asia/Taipei"
        }
      },
      "Location": {
        "type": "select",
        "select": {
          "name": location,
        }
      }
    }
  };

  final response = await http.post(Uri.parse('https://api.notion.com/v1/pages'),
      headers: {
        'Authorization': 'Bearer ' "${notionSecret}" '',
        "Content-Type": "application/json",
        "Notion-Version": "2022-06-28"
      },
      body: jsonEncode(requestBody));

  if (response.statusCode == 200) {
    return jsonDecode(response.body)["id"];
  }

  return "database upload failed";
}

Future<String> addPhotoToNotionPage(String pageId, XFile image) async {
  final response = await http.patch(
      Uri.parse('https://api.notion.com/v1/blocks/${pageId}/children'),
      headers: {
        'Authorization': 'Bearer ' "${notionSecret}" '',
        "Content-Type": "application/json",
        "Notion-Version": "2022-06-28"
      },
      body: json.encode({
        "children": [
          {
            "object": "block",
            "type": "image",
            "image": {
              "type": "external",
              "external": {"url": await uploadImageToImgur(image)}
            }
          }
        ]
      }));
  if (response.statusCode == 200) {
    return 'success';
  }
  return response.body;
}

void main() async {
  final response = await http.get(
      Uri.https('api.notion.com', '/v1/databases/${databaseId}'),
      headers: {
        'Authorization': 'Bearer ' "${notionSecret}" '',
        "Content-Type": "application/json",
        "Notion-Version": "2022-06-28"
      });

  final json = jsonDecode(response.body.toString());

  print(json['properties']);

  final map = {
    "object": "test_object",
    "description": ["test1", "test2", "test3"],
    "color": ["testA", "testB"]
  };

  print(await uploadFoundObject(map, 'G07-Gongguan'));
}
