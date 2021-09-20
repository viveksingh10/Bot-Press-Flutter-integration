import 'dart:convert';
import 'dart:io';

Future requestBotPressServer(msg) async {
  List<dynamic> data;
  String url =
      'https://virtusa-bot.herokuapp.com/api/v1/bots/appointments/converse/userId';
  Map jsonMap = {'type': 'text', 'text': msg};
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  if (response.statusCode == 200) {
    String reply = await response.transform(utf8.decoder).join();
    data = json.decode(reply)["responses"];
  } else {
    throw Exception('Chatbot server is down');
  }
  httpClient.close();
  return data;
}
