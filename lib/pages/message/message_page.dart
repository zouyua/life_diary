import 'package:flutter/material.dart';

/// 消息页
class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('消息页 - 待实现'),
      ),
    );
  }
}
