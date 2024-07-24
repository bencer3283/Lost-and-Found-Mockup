# lost_and_found_mockup

A Flutter app intended to act as a mock-up and technical evaluation of a smart lost & found kiosk project. The app takes a picture of an object, upload it to **claude.ai** to be identified by the large foundation model. The app then store the image and identification information to a database implemented with **Notion**.

## Inside `lib\`
- [`claude.dart`](.\lib\claude.dart): contains a function that uploads an image and a prompt to claude.ai. Returns a JSON object that contains identification information to be used to render UI and uploaded to the database.
- [`notion.dart`](.\lib\notion.dart): contains founction `uploadFoundObject` and `addPhotoToNotionPage`.
  -  `uploadFoundObject`: upload the identification information to a Notion database and thus create a page inside the database. (Every entry in a Notion database is a page.)
  -  `addPhotoToNotionPage`: upload the taken image to **Imgur.io** with a function in `imgur.dart` then use the returned Imgur URL to add the photo to the created page/database entry for the object.
- [`imgur.dart`](.\lib\imgur.dart): contains a function to upload the photo of the object to Imgur.io since Notion does not support direct image upload through its API. 

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
