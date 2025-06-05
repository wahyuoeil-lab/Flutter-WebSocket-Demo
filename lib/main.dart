import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebSocket _webSocket;
  final _serverUrl = 'wss://echo.websocket.org'; // contoh server WebSocket echo
  final _controller = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      _webSocket = await WebSocket.connect(_serverUrl);
      _webSocket.listen((data) {
        setState(() {
          _messages.add("Server: $data");
        });
      }, onDone: () {
        setState(() {
          _messages.add("Connection closed");
        });
      }, onError: (error) {
        setState(() {
          _messages.add("Error: $error");
        });
      });
      setState(() {
        _messages.add("Connected to WebSocket");
      });
    } catch (e) {
      setState(() {
        _messages.add("Failed to connect: $e");
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _webSocket.add(_controller.text);
      setState(() {
        _messages.add("You: ${_controller.text}");
      });
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _webSocket.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter WebSocket Demo')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_messages[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
