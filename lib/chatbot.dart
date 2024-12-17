import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];

  final Map<int, String> _faqAnswers = {
    1: "To submit your clearance requirements, go to the 'Upload Documents' section in the app and follow the prompts to upload your files.",
    2: "You can check your clearance status by navigating to the 'Clearance Status' section in the app. It will show which requirements are approved or pending.",
    3: "The required documents are listed in the 'Requirements' section of the app. You can find specific instructions there for each department.",
    4: "If a document is rejected, you can re-upload it by going to the 'Upload Documents' section and selecting the rejected requirement. Make sure your new file meets the stated requirements.",
    5: "Thank you for using the chatbot! Goodbye!"
  };

  void _sendMessage(String userMessage) {
    if (userMessage.isEmpty) return;

    setState(() {
      // Add user's message
      _chatMessages.add({"message": userMessage, "sender": "user"});

      // Check if the user typed a number and respond with the corresponding answer
      int? selectedOption = int.tryParse(userMessage);
      if (selectedOption != null && _faqAnswers.containsKey(selectedOption)) {
        // Add the bot's response based on the selected option
        _chatMessages.add({"message": _faqAnswers[selectedOption]!, "sender": "bot"});

        // Re-display the options unless the user chooses to exit
        if (selectedOption != 6) {
          _chatMessages.add({
            "message": "1. How do I submit my clearance requirements?\n"
                "2. How do I check my clearance status?\n"
                "3. How do I know which documents are required?\n"
                "4. How do I resolve issues with a rejected document?\n"
                "5. Exit",
            "sender": "bot",
          });
        }
      } else {
        _chatMessages.add({"message": "Please select a valid option (1-6).", "sender": "bot"});
      }
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clearance Chatbot"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the options at the top-left like a bot message
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(maxWidth: 250),
                      child: Text(
                        "1. How do I submit my clearance requirements?\n"
                        "2. How do I check my clearance status?\n"
                        "3. How do I know which documents are required?\n"
                        "4. How do I resolve issues with a rejected document?\n"
                        "5. Exit",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),

                  // Chat messages display area
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = _chatMessages[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: message['sender'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: message['sender'] == 'user' ? Colors.blue : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text(
                              message['message']!,
                              style: TextStyle(
                                color: message['sender'] == 'user' ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Input field for typing the selected number (1-6)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter a number (1-5)'),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
