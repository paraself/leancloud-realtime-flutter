import 'package:leancloud_realtime_flutter/AVIMMessage.dart';
import 'package:leancloud_realtime_flutter/AVIMMessageMediaType.dart';
import 'dart:convert';


class MessageQueryEndpoint{
  MessageQueryEndpoint({this.messageID,this.sentTimestamp,this.isClosed = false});

  /// The ID of the endpoint(message).
  String messageID;
  
  /// The sent timestamp of the endpoint(message).
  int sentTimestamp;
  
  /// Interval open or closed.
  bool isClosed = false;

  Map<String, dynamic> encoding(){
    return {
      "messageID":messageID,
      "sentTimestamp":sentTimestamp,
      "isClosed":isClosed,
    };
  }
}

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



  decoding(Map<String, dynamic> data){
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
    if(data['attributes']!=null){
      this.attributes = data['attributes'].map((a, b) => MapEntry(a as String, b));
    }
  }
}

class AVIMFileMessageBase extends AVIMTypedMessage{
  AVIMFileMessageBase({
    this.url,mediaType:int
  }){
    this.mediaType = mediaType;
  }
  Map<String, Object> fileMetaData;
  String url;
  // public IProgress<AVUploadProgressEventArgs> FileUploadProgress { get; set; }

  
  @override
  decoding(Map<String, Object> data){
    super.decoding(data);
    print(jsonEncode(data));
    // this.url = data['url'];
    // this.fileMetaData?.keys;
    var file = this.rawData['_lcfile'] as Map<String, Object>;
    if(file!=null){
      this.fileMetaData = file['metaData'];
      this.url = file['url'];
    }
  }

}

class AVIMAudioMessage extends AVIMFileMessageBase{
  AVIMAudioMessage():super(mediaType:AVIMMessageMediaType.Audio);
}

class AVIMFileMessage extends AVIMFileMessageBase{
  AVIMFileMessage():super(mediaType:AVIMMessageMediaType.File);
}

class AVIMImageMessage extends AVIMFileMessageBase{
  AVIMImageMessage():super( mediaType:AVIMMessageMediaType.Image);
}

class AVIMVideoMessage extends AVIMFileMessageBase{
  AVIMVideoMessage():super(mediaType:AVIMMessageMediaType.Video);
}

class AVIMTextMessage extends AVIMFileMessageBase{
  AVIMTextMessage():super(mediaType:AVIMMessageMediaType.Text);
}