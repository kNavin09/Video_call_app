import 'package:flutter/material.dart';
import 'package:hipster_assignment/prasentation/video_call_screen/video_call_screen.dart';
//optional 
class IncomingCallScreen extends StatelessWidget {
  final String channelId;
  final String callerName;

  const IncomingCallScreen({
    Key? key,
    required this.channelId,
    required this.callerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Incoming call from $callerName",
                style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoCallScreen(
                          channelId: channelId,
                          isIncoming: true,
                        ),
                      ),
                    );
                  },
                  child: const Text("Accept"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Reject"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
