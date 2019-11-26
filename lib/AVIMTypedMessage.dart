import 'package:leancloud_realtime_flutter/AVIMMessage.dart';
import 'package:leancloud_realtime_flutter/AVIMMessageMediaType.dart';

class AVIMTypedMessage extends AVIMMessage{
  /**
   * 自定义属性
   */
  Map<String,dynamic> attributes;

  /**
   * AVIMMessageMediaType
   */
  int mediaType;

  String title;

  String text;

  /**
   * 富媒体消息的消息体，默认 LeanCloud 采用的是 JSON 的编码格式发送消息。
   */
  Map<String,dynamic> typedMessageBody;



  decoding(Map<String, Object> data){
      this.rawData = data["rawData"] ;
      this.conversationId = data["conversationId"] ;
      this.fromClientId = data["fromClientId"] ;
      this.id = data["id"] ;
      this.messageStatus = AVIMMessage.IntToStatus(data["messageStatus"] );
      this.readTimestamp = data["readTimestamp"] ;
      this.sentTimestamp = data["sentTimestamp"] ;
      this.deliveredTimestamp = data["deliveredTimestamp"] ;
      this.isAllMembersMentioned = data["isAllMembersMentioned"] ;
      this.mentionedMembers = data["mentionedMembers"] ;
      this.isCurrentClientMentioned = data["isCurrentClientMentioned"] ;

      this.text = data["text"] ;
      this.attributes = data["attributes"] ;
  }
}