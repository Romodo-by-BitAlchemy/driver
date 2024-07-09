import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DriverChatPage extends StatefulWidget {
  final String passengerName;

  DriverChatPage({required this.passengerName});

  @override
  _DriverChatPageState createState() => _DriverChatPageState();
}

class _DriverChatPageState extends State<DriverChatPage> {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String currentUserId = 'driver_unique_user_id';
  late String groupChatId;
  List<DocumentSnapshot> listMessages = [];

  @override
  void initState() {
    super.initState();
    groupChatId = '${currentUserId}-${widget.passengerName}';
  }

  bool isMessageSent(int index) {
    return (index > 0 && listMessages[index - 1].get('idFrom') != currentUserId) || index == 0;
  }

  bool isMessageReceived(int index) {
    return (index > 0 && listMessages[index - 1].get('idFrom') == currentUserId) || index == 0;
  }

  void onSendMessage(String content) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      var documentReference = firestore.collection('messages').doc(groupChatId).collection(groupChatId).doc(DateTime.now().millisecondsSinceEpoch.toString());

      firestore.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': currentUserId,
            'idTo': widget.passengerName,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': 0,
          },
        );
      });
      scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nothing to send')));
    }
  }

  Widget buildMessageInput() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: TextField(
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: 'Write here...',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text);
                },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 4, right: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              onPressed: () {
                onSendMessage(textEditingController.text);
              },
              icon: Icon(Icons.send_rounded),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      var chatMessages = documentSnapshot.data() as Map<String, dynamic>;
      int currentMessageTimestamp = int.parse(chatMessages['timestamp']);
      int previousMessageTimestamp = index > 0
          ? int.parse(listMessages[index - 1].get('timestamp'))
          : currentMessageTimestamp;
      bool isNewGroup = (currentMessageTimestamp - previousMessageTimestamp) > 120000;

      if (chatMessages['idFrom'] == currentUserId) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                chatMessages['type'] == 0
                    ? messageBubble(
                        chatContent: chatMessages['content'],
                        color: Colors.blue,
                        textColor: Colors.white,
                        margin: EdgeInsets.only(right: 10),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            isMessageSent(index)
                ? Container(
                    margin: EdgeInsets.only(right: 50, top: 6, bottom: 8),
                    child: Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(currentMessageTimestamp),
                      ),
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(height: isNewGroup ? 10 : 0),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                chatMessages['type'] == 0
                    ? messageBubble(
                        color: Colors.grey[300]!,
                        textColor: Colors.black,
                        chatContent: chatMessages['content'],
                        margin: EdgeInsets.only(left: 10),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            isMessageReceived(index)
                ? Container(
                    margin: EdgeInsets.only(left: 50, top: 6, bottom: 8),
                    child: Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(currentMessageTimestamp),
                      ),
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(height: isNewGroup ? 10 : 0),
          ],
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('messages').doc(groupChatId).collection(groupChatId).orderBy('timestamp', descending: true).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessages = snapshot.data!.docs;
                  if (listMessages.isNotEmpty) {
                    return ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: snapshot.data?.docs.length,
                        reverse: true,
                        controller: scrollController,
                        itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]));
                  } else {
                    return Center(child: Text('No messages...'));
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              })
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.passengerName}')),
      body: Column(
        children: [
          buildListMessage(),
          buildMessageInput(),
        ],
      ),
    );
  }
}

Widget messageBubble({
  required String chatContent,
  required Color color,
  required Color textColor,
  required EdgeInsets margin,
}) {
  return Container(
    padding: EdgeInsets.all(10),
    margin: margin,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      chatContent,
      style: TextStyle(color: textColor),
    ),
  );
}































































