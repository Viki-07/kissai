import 'package:flutter/material.dart';
import 'package:kissai/lgfunctions.dart';
import 'package:kissai/provider/sshprovider.dart';

import 'package:provider/provider.dart';
import 'package:dartssh2/dartssh2.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController ipController = TextEditingController(text: '');
  TextEditingController usernameController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController portController = TextEditingController(text: '');
  TextEditingController rigsController = TextEditingController(text: '');

//initializing all the text editing controllers used in settings screen.
  initTextControllers(BuildContext context) {
    ipController.text =
        Provider.of<SSHClientProvider>(context, listen: false).ip;
    usernameController.text =
        Provider.of<SSHClientProvider>(context, listen: false).username;
    passwordController.text =
        Provider.of<SSHClientProvider>(context, listen: false).password;
    portController.text =
        Provider.of<SSHClientProvider>(context, listen: false).port.toString();
    rigsController.text =
        Provider.of<SSHClientProvider>(context, listen: false).rigs.toString();
  }

//updating all the text editing controllers when they are changed
  updateProviders(BuildContext context) {
    Provider.of<SSHClientProvider>(context, listen: false).ip =
        ipController.text;
    Provider.of<SSHClientProvider>(context, listen: false).username =
        usernameController.text;
    Provider.of<SSHClientProvider>(context, listen: false).password =
        passwordController.text;
    Provider.of<SSHClientProvider>(context, listen: false).port =
        int.parse(portController.text);
    Provider.of<SSHClientProvider>(context, listen: false).rigs =
        int.parse(rigsController.text);
  }

  @override
  void initState() {
    super.initState();
    initTextControllers(context);
  }

  Future<void> ConnectingDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            'Connecting...',
          ),
        );
      },
    );
  }

  Future<void> connectionStatusDialog(
      String connectionStatus, BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Text(
            connectionStatus,
          ),
        );
      },
    );
  }

  Widget customInput(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.all(7),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
        ),
      ),
    );
  }

  @override
  void dispose() {
    ipController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    portController.dispose();
    rigsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SSHClientProvider>(
      builder: (context, sshclientprovider, child) => SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (sshclientprovider.isConnected)
                        Text("Connected",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                      else
                        Text(
                          "Disconnected",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  customInput(ipController, "IP Address"),
                  customInput(usernameController, "Username"),
                  customInput(passwordController, "Password"),
                  customInput(portController, "Port"),
                  customInput(rigsController, "Rigs"),
                  ElevatedButton(
                    onPressed: () async {
                      updateProviders(context);

                      try {
                        ConnectingDialog(context);
                        final client = SSHClient(
                          await SSHSocket.connect(
                                  sshclientprovider.ip, sshclientprovider.port)
                              .timeout(Duration(seconds: 5)),
                          username: sshclientprovider.username,
                          onPasswordRequest: () => sshclientprovider.password,
                        );
                        sshclientprovider.client = client;
                        setState(() {
                          sshclientprovider.isConnected = true;
                        });
                        Navigator.pop(context);
                        connectionStatusDialog(
                            sshclientprovider.ip + " is Connected !", context);
                      } catch (e) {
                        Navigator.pop(context);
                        connectionStatusDialog(
                            sshclientprovider.ip + " is not reachable !",
                            context);
                        setState(() {
                          sshclientprovider.isConnected = false;
                        });
                      }
                    },
                    child: const Text('Connect To LG'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setRefresh(sshclientprovider);
                      },
                      child: Text("Set Refresh"))
                  // ElevatedButton(
                  //   onPressed: () {
                  //     LGFunctions().cleanlogos(sshclientprovider);
                  //   },
                  //   child: const Text('Clean Logos'),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
