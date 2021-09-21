import 'package:flutter/material.dart';
import 'package:app/palette.dart';
import 'package:app/chat_message.dart';
import 'package:app/sevices.dart';
import 'package:progress_indicators/progress_indicators.dart';

class Bot extends StatefulWidget {
  @override
  _Bot createState() => new _Bot();
}

class _Bot extends State<Bot> {
  String resultText = "";
  String botName = "Loki";
  String userName = "You";
  final List<ChatMessage> _messages = <ChatMessage>[];
  List<dynamic> btnlist = <dynamic>[];
  final TextEditingController _textController = new TextEditingController();

  void _handleSubmitted(String text) async {
    _textController.clear();
    createAndInsertMessage(text, userName);
    getDataFromBotpress(text);
  }

  Widget loadingBotPress() {
    return Center(
        child: JumpingText('Loading...',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 25.0)));
  }

  Widget dynamicChips() {
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: List<Widget>.generate(btnlist.length, (int index) {
        return FlatButton(
          hoverColor: Colors.green,
          focusColor: Colors.red,
          color: Colors.deepPurple[200],
          child: Text(btnlist[index]),
          onPressed: () async {
            _handleSubmitted(btnlist[index]);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    getDataFromBotpress("reset");
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFAD9FE4), Palette.primaryColor],
        ),
      ),
      child: new Scaffold(
        backgroundColor: Colors.transparent,
        appBar: new AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFAD9FE4), Palette.primaryColor],
              ),
            ),
          ),
          centerTitle: true,
          title: new Text(
            "Ask Loki",
            style: TextStyle(
                fontSize: 30.0, color: Colors.white70, fontFamily: "Signatra"),
          ),
          actions: <Widget>[
            IconButton(
              icon: Image(image: AssetImage("assets/images/reset.png")),
              onPressed: () {
                _handleSubmitted("reset");
              },
            ),
          ],
        ),
        body: new Column(children: <Widget>[
          new Flexible(
              child: (_messages.length != 0)
                  ? new ListView.builder(
                      padding: new EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) => _messages[index],
                      itemCount: _messages.length,
                    )
                  : loadingBotPress()),
          new Divider(height: 1.0),
          new Container(
            child: dynamicChips(),
          ),
          new Container(
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFAD9FE4), Palette.primaryColor],
              ),
            ),
            child: IconTheme(
              data: new IconThemeData(
                color: Theme.of(context).accentColor,
              ),
              child: new Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: new Row(
                  children: <Widget>[
                    new Flexible(
                      child: new TextField(
                        cursorColor: Colors.black,
                        controller: _textController,
                        decoration: new InputDecoration.collapsed(
                            hintText: "Send a message"),
                      ),
                    ),
                    new Container(
                      child: Center(
                        child: new IconButton(
                            splashColor: Colors.red,
                            icon: new Icon(
                              Icons.send,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              _handleSubmitted(_textController.text);
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void getDataFromBotpress(String msg) async {
    List<dynamic> data = await requestBotPressServer(msg);
    btnlist.clear();
    for (var i = 0; i < data.length; i++) {
      if (data[i]['type'] == "text") {
        createAndInsertMessage(data[i]['text'], botName);
      }
      if (data[i]['type'] == "custom") {
        List<dynamic> buttonlist = data[i]["quick_replies"];
        for (var j = 0; j < buttonlist.length; j++) {
          if (buttonlist[j]['title'] != "Reset") {
            btnlist.add(buttonlist[j]['title']);
          }
        }
      }
    }
  }

  void createAndInsertMessage(msgText, name) {
    ChatMessage message = new ChatMessage(
      text: msgText,
      name: name,
      type: name != botName,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }
}
