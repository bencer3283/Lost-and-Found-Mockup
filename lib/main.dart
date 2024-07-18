import 'dart:convert';
import 'dart:io';
import 'claude.dart';
import 'notion.dart';
import 'package:flutter/material.dart';

const imageLink =
    'images/hand-holding-leather-blue-wallet-purse-isolated-white-background_41158-702.jpeg';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost and Found Mockup',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 99, 173, 68)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _locationController =
      TextEditingController.fromValue(TextEditingValue(text: 'G07-Gongguan'));

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      width: 5, color: Theme.of(context).primaryColor),
                  image: const DecorationImage(
                      image: AssetImage(imageLink), fit: BoxFit.cover),
                )),
            Container(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: _locationController,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(IdentifyObjectScreen(
            identifyOdjectWithClaude(image: AssetImage(imageLink)),
            _locationController.text)),
        tooltip: 'Scan',
        child: const Icon(Icons.remove_red_eye),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class IdentifyObjectScreen<T> extends PopupRoute<T> {
  final Future identifyResult;
  final String location;
  IdentifyObjectScreen(this.identifyResult, this.location) {}
  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  // This allows the popup to be dismissed by tapping the scrim or by pressing
  // the escape key on the keyboard.
  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismissible Dialog';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    bool isComplete = false;
    return Center(
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: Container(
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.background),
          child: FutureBuilder(
            future: identifyResult,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final jsonresult = jsonDecode(snapshot.data);
                final object = jsonresult['object'];
                final descriptions = jsonresult['description'];
                final color = jsonresult['color'];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      object.toString().toUpperCase(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      descriptions[0] +
                          ', ' +
                          descriptions[1] +
                          ', ' +
                          descriptions[2],
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .fontSize),
                    ),
                    Text(
                      color[0] + ', ' + color[1],
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .fontSize),
                    ),
                    Container(
                        alignment: Alignment.bottomRight,
                        child: UploadButton(jsonresult, location))
                  ],
                );
              } else {
                return Text(
                  'Identifying......',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize:
                          Theme.of(context).textTheme.headlineMedium!.fontSize),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class UploadButton extends StatefulWidget {
  const UploadButton(this.payload, this.location, {super.key});
  final payload;
  final location;

  @override
  State<UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<UploadButton> {
  bool isComplete = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          uploadFoundObject(widget.payload, widget.location).then((value) {
            setState(() {
              isComplete = true;
            });
            Future.delayed(Duration(milliseconds: 600))
                .then((value) => Navigator.of(context).pop());
          }, onError: (err) {});
        },
        child: Text(isComplete ? 'Completed' : 'Upload'));
  }
}
