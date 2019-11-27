import 'package:leancloud_realtime_flutter/AVFile.dart';
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
    var out = {
      "messageID":messageID,
      "sentTimestamp":sentTimestamp,
      "isClosed":isClosed,
    };
    out.removeWhere((k,v)=>v==null);
    return out;
  }
}


/// Message IO Type.
enum AVIMMessageIOType {
  isIn,
  isOut,
}

  /// The reason of the message being patched.
class PatchedReason {
    PatchedReason(Map<String, Object> data){
      decoding(data);
    }
    decoding(Map<String, Object> data){
      this.code = data['code'];
      this.reason = data['reason'];
    }
    int code;
    String reason;
}

enum AVIMMessageStatus{
  failed,
  none ,
  /**
   * 正在发送
   */
  sending,
  /**
   * 已发送
   */
  sent,
  /**
   * 已送达
   */
  delivered,
  read,
}

class AVIMMessage {
  AVIMMessage({
    this.mediaType,String filePath
  }){
    if(filePath!=null){
      this.file = new AVFile(filePath: filePath);
    }
  }
  /**
   * 消息的原始数据, 自定义消息内容,也存储在其中
   */
  Map<String, dynamic> rawData = new Map<String, dynamic>();

  /**
   * 对话的Id
   */
  String conversationId;

  /**
   * 发送消息的 ClientId
   */
  String fromClientId;

  /**
   * 	
  消息在全局的唯一标识Id
   */
  String id;

  /**
   * 消息的状态 - AVIMMessageStatus
   */
  AVIMMessageStatus messageStatus;
  // /**
  //  * 服务器端的时间戳
  //  */
  // int serverTimestamp;
  int readTimestamp;
  int sentTimestamp;
  int deliveredTimestamp;
  // /**
  //  * 是否为暂态消息
  //  */
  // bool transient;

    /// Feature: @all.
  bool isAllMembersMentioned;
    /// Feature: @members.
  List<String> mentionedMembers;
    /// Indicates whether the current client has been @.
  bool isCurrentClientMentioned;



  static AVIMMessageStatus IntToStatus(int code){
    switch(code){
      case -1: return AVIMMessageStatus.failed;
      case 1: return AVIMMessageStatus.sending;
      case 2: return AVIMMessageStatus.sent;
      case 3: return AVIMMessageStatus.delivered;
      case 4: return AVIMMessageStatus.read;
      default:
      return AVIMMessageStatus.none;
    }
  }

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

  AVFile file;

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
      this.attributes = (data['attributes'] as Map<dynamic, dynamic>).map<String,dynamic>((a, b) => MapEntry(a as String, b));
    }

    var file = this.rawData['_lcfile'] as Map<String, Object>;
    if(file!=null){
      this.file = new AVFile();
      this.file.decoding(file);
    }
  }

  Map<String, dynamic> encoding(){
    var out = {
      "rawData":rawData,
      "text":text,
      "file":file?.encoding(),
      "attributes":attributes,
      "isAllMembersMentioned":isAllMembersMentioned,
      "mentionedMembers":mentionedMembers,
    };
    out.removeWhere((k,v)=>v==null);
    return out;
  }
  // Map<String, Object> fileMetaData;
  String get url {
    return file?.url;
  }

  dynamic getMetaData(String key){
    if(file?.metaData!=null){
      return file.metaData[key];
    }
  }
}


class AVIMAudioMessage extends AVIMMessage{
  AVIMAudioMessage({String filePath}):super(mediaType:AVIMMessageMediaType.Audio,filePath:filePath);

    
  /// The data size of image.
  double get duration {
      return getMetaData('duration');
  }
    
  /// The data size of image.
  double get size {
      return getMetaData('size');
  }
  
  /// The format of image.
  String get format {
      return getMetaData('format');
  }
}

class AVIMFileMessage extends AVIMMessage{
  AVIMFileMessage({String filePath}):super(mediaType:AVIMMessageMediaType.File,filePath:filePath);

  /// The data size of image.
  double get size {
      return getMetaData('size');
  }
  
  /// The format of image.
  String get format {
      return getMetaData('format');
  }
}

class AVIMImageMessage extends AVIMMessage{
  AVIMImageMessage({String filePath}):super( mediaType:AVIMMessageMediaType.Image,filePath:filePath);

    
    /// The width of image.
    double get width {
        return getMetaData('getMetaData');
    }
    
    /// The height of image.
    double get height {
        return getMetaData('getMeheighttaData');
    }
    
    /// The data size of image.
    double get size {
        return getMetaData('size');
    }
    
    /// The format of image.
    String get format {
        return getMetaData('format');
    }
}

class AVIMVideoMessage extends AVIMMessage{
  AVIMVideoMessage():super(mediaType:AVIMMessageMediaType.Video);

    
  /// The data size of image.
  double get duration {
      return getMetaData('duration');
  }
    
  /// The data size of image.
  double get size {
      return getMetaData('size');
  }
  
  /// The format of image.
  String get format {
      return getMetaData('format');
  }
}

class AVIMTextMessage extends AVIMMessage{
  AVIMTextMessage():super(mediaType:AVIMMessageMediaType.Text);
}