import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:groq/groq.dart';
import 'package:kissai/lgfunctions.dart';
import 'package:kissai/provider/sshprovider.dart';
import 'package:kissai/screens/settings.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

void showSnackbar(BuildContext context, String error) {
  final snackBar = SnackBar(
    content: Text(error),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

final _groq =
    Groq(apiKey: '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');
var searchText = new TextEditingController();
var responseText = "";
Future<String> sendMessage(String searchText) async {
  GroqResponse response = await _groq.sendMessage(searchText);
  return response.choices.first.message.content;
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _groq.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SSHClientProvider>(
      builder: (context, sshclientprovider, child) => Scaffold(
        appBar: AppBar(
          title: Text(""),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ));
                },
                icon: Icon(Icons.settings))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 500,
                      child: TextFormField(
                        controller: searchText,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50))),
                      )),
                  SizedBox(width: 100),
                  ElevatedButton(
                      onPressed: () async {
                        if (searchText.text.isNotEmpty) {
                          responseText = "";
                          final res = await sendMessage(searchText.text);
                          // goToPlace(searchText.text, sshclientprovider);
                          cleanVisualization(sshclientprovider);
                          setState(() {
                            responseText = res;
                          });
                          openBalloon(
                              'Maurya',
                              searchText.text,
                              'hu',
                              5,
                              responseText,
                              'Groq AI',
                              'fdsaf',
                              sshclientprovider);

                          // searchText.clear();
                        } else {
                          showSnackbar(context, "Search Something...");
                        }
                      },
                      child: Container(
                        height: 60,
                        width: 120,
                        child: Center(
                          child: Text(
                            "Search",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      )),
                  // ElevatedButton(
                  //     onPressed: () {
                  //       relaunchLG(sshclientprovider);
                  //     },
                  //     child: Text("raluach"))
                ],
              ),
              Text(responseText),
            ],
          ),
        ),
      ),
    );
  }
}
