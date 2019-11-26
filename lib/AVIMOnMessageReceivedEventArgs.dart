import 'package:leancloud_realtime_flutter/AVIMConversation.dart';
import 'package:leancloud_realtime_flutter/AVIMMessage.dart';

/**
 * 收到消息时激发的事件参数，它提供消息所在的对话（Conversation）和消息（Message）本身。
 */
class AVIMOnMessageReceivedEventArgs{
  AVIMConversation conversation;
  AVIMMessage message ;
}