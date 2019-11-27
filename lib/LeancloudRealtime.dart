import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:leancloud_realtime_flutter/AVIMConversation.dart';
import 'package:leancloud_realtime_flutter/Message.dart';
import 'package:leancloud_realtime_flutter/AVIMMessageMediaType.dart';

class LeancloudRealtime {
  static const MethodChannel _channel =
      const MethodChannel('leancloud_realtime_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static AVIMMessage _CreateMessage(Map<dynamic,dynamic> arguments){
      var data = arguments.map((a, b) => MapEntry(a as String, b));
      if(data["content"]!=null){
        data["rawData"] = jsonDecode( data["content"] );
      }
      var mediaType = data["mediaType"];
      if(mediaType==null && data["rawData"]!=null){
        mediaType = data["rawData"]["_lctype"] ;
      }
      if(mediaType==null ){
        print('mediaType==null rawData '+data["content"]);
        throw new ArgumentError('mediaType==null rawData '+data["content"] );
      }
      var messageFactory = _messageFactoryMap[mediaType];
      if(messageFactory==null){
        print('missing messageFactory ' + mediaType.toString() +' rawData '+data["content"] );
        throw new ArgumentError('missing messageFactory ' + mediaType.toString() +' rawData '+data["content"] );
      }
      var message = messageFactory();
      message.decoding(data);
      return message;
  }

  static Map<String,AVIMConversation> _conversations = new Map<String,AVIMConversation>();
  static AVIMConversation _CreateConversation(String id){
    var conversation = _conversations[id];
    if(conversation==null){
      conversation = new AVIMConversation(conversationId: id);
      _conversations[id] = conversation;
    }
    return conversation;
  }

  static AVIMConversation _UpdateConversation(Map<dynamic,dynamic> arguments){
      var data = arguments.map((a, b) => MapEntry(a as String, b));
      if(data["lastMessage"]!=null){
        data["lastMessage"] = _CreateMessage(data["lastMessage"]);
      }
      var conversation = _CreateConversation(data["conversationId"]);
      conversation.decoding(data);
      return conversation;
  }

  static Future<dynamic> _handler(MethodCall call){
    try
    {

      print('LeancloudRealtime.handler '+call.method);
      print(call.arguments);
      // print(OnMessageReceived);
      // print(OnMessageUpdated);
      // print(OnMessageDelivered);
      // print(OnMessageRead);
      switch(call.method){
        case 'OnMessageReceived':
        if(OnMessageReceived!=null){
          OnMessageReceived(_CreateMessage(call.arguments));
        }
        break;
        case 'OnMessageUpdated':
        if(OnMessageUpdated!=null){
          OnMessageUpdated(_CreateMessage(call.arguments[0]),call.arguments[1]!=null?new PatchedReason(call.arguments[1]):null);
        }
        break;
        case 'OnMessageDelivered':
        if(OnMessageDelivered!=null){
          OnMessageDelivered(call.arguments[0],call.arguments[1],call.arguments[3]);
        }
        break;
        case 'OnMessageRead':
        if(OnMessageRead!=null){
          OnMessageRead(call.arguments[0],call.arguments[1],call.arguments[3]);
        }
        break;
        case 'OnProgressCallback':{
          _OnProgressCallback(call.arguments[0],call.arguments[1]);
        }
        break;
      }
    }
     on Error catch(error){
      print(error);
      print(error.stackTrace);
    }
    catch(error){
      print(error);
    }
  }

  static bool inited = false;
  static Init({String id,String key,String serverURL = "https://leancloud.cn"}){
    if(inited){
      print("repeat init");
      return null;
    }
    _channel.setMethodCallHandler(_handler);

    registerCustomMessage(AVIMMessageMediaType.Text, ()=> new AVIMTextMessage());
    registerCustomMessage(AVIMMessageMediaType.Image, ()=> new AVIMImageMessage());
    registerCustomMessage(AVIMMessageMediaType.Audio, ()=> new AVIMAudioMessage());
    registerCustomMessage(AVIMMessageMediaType.File, ()=> new AVIMFileMessage());
    inited = true;
    return _channel.invokeMethod('Init',<String, String>{
        'id': id,
        'key':key,
        'serverURL':serverURL
      });
  }

  static Future<void>  become(String sessionToken)  async {
    var result = await _channel.invokeMethod('become',sessionToken);
    print(result);
  }

  static Future<void>  close()  async {
    await _channel.invokeMethod('close');
  }

  static Future<List<AVIMMessage>>  QueryMessage(AVIMConversation conversation,Map<String,dynamic> params)  async {
    params["conversationId"] = conversation.conversationId;
    var result = (await _channel.invokeMethod('QueryMessage',params)) as List<dynamic>;
    // var list = new List<AVIMMessage>();
    // result.fo
    return result?.map((f)=>_CreateMessage(f as Map<dynamic,dynamic>)).toList();
  }

  static void registerCustomMessage(int mediaType,AVIMMessageFactory messageFactory){
    _messageFactoryMap[mediaType] = messageFactory;
  }

  static Future<List<AVIMConversation>> getConversations(List<String> IDs)  async{
    var result = await _channel.invokeMethod('getConversations',IDs) as List<dynamic>;
    return result?.map((f)=>_UpdateConversation(f)).toList();
  }

/**
 * clientIDs：必要参数，包含对话的初始成员列表，请注意当前用户作为对话的创建者，是默认包含在成员里面的，所以 members 数组中可以不包含当前用户的 clientId。
 * name：对话名字，可选参数，
 * attributes：对话的自定义属性，可选。上面示例代码没有指定额外属性，开发者如果指定了额外属性的话，以后其他成员可以通过 AVIMConversation 的接口获取到这些属性值。附加属性在 _Conversation 表中被保存在 attr 列中
 * isUnique  唯一对话标志位，可选。
 *  如果设置为唯一对话，云端会根据完整的成员列表先进行一次查询，如果已经有正好包含这些成员的对话存在，那么就返回已经存在的对话，否则才创建一个新的对话。
 *  如果指定 isUnique 标志为假，那么每次调用 createConversation 接口都会创建一个新的对话
 */
  static Future<AVIMConversation> CreateConversation(List<String> clientIDs,{
    String name,
    Map<String, dynamic> attributes,bool isUnique = true,
  })  async{

    dynamic result = await _channel.invokeMethod('CreateConversation',{
      "clientIDs":clientIDs,
      "name":name,
      "attributes":attributes,
      "isUnique":isUnique
    }) ;
    return _UpdateConversation(result);
  }

  static void ConversationRead(AVIMConversation conversation)   async{
    _channel.invokeMethod('ConversationRead',conversation.conversationId); 
  }

  static void ConversationSendText(AVIMConversation conversation,String text)   async{
    return _channel.invokeMethod('ConversationSendText',[conversation.conversationId,text]); 
  }
  static int _progressCallbackIndex = 0;
  static Map<int,Event<num>> _progressCallbackMap = new Map<int,Event<num>>();

  static _OnProgressCallback(int index,double progress){
    if(_progressCallbackMap[index]!=null){
      _progressCallbackMap[index](progress);
    }else{
      print("missing progressCallback Index "+index.toString());
    }
  }

  static Future ConversationSendMessage(AVIMConversation conversation,AVIMMessage message,{
    Map<dynamic,dynamic> pushData,
    Event<num>progress
  })   async{
    int progressCallbackIndex;
    if(progress!=null){
      progressCallbackIndex = _progressCallbackIndex++;
      _progressCallbackMap[progressCallbackIndex] = progress;
    }
    message.messageStatus = AVIMMessageStatus.sending;
    try{
      var args = {
        "mediaType":message.mediaType,
        "conversationId":conversation.conversationId,
        "message":message.encoding(),
        "pushData":pushData,
        "progress":progressCallbackIndex
      };
      args.removeWhere((k,v)=>v==null);
      var result = (await _channel.invokeMethod('ConversationSendMessage',args)) as Map<dynamic,dynamic>; 
      print("ConversationSendMessage finish");
      message.messageStatus = AVIMMessageStatus.sent;
      if(progressCallbackIndex!=null){
        _progressCallbackMap.remove(progressCallbackIndex);
      }

      if(result["content"]!=null){
        result["rawData"] = jsonDecode( result["content"] );
      }

      message.decoding(result.map((a, b) => MapEntry(a as String, b)));
      return message;
    }catch(error){
      message.messageStatus = AVIMMessageStatus.failed;
      if(progressCallbackIndex!=null){
        _progressCallbackMap.remove(progressCallbackIndex);
      }
      throw error;
    }
  }
  

  static Map<int,AVIMMessageFactory> _messageFactoryMap = new Map<int,AVIMMessageFactory>();
  /**
   * received(message: IMMessage)
   */
  static Event<AVIMMessage> OnMessageReceived;
  /**
   * updated(updatedMessage: IMMessage, reason: IMMessage.PatchedReason?)
   */
  static Event2<AVIMMessage,PatchedReason> OnMessageUpdated;
  /**
   * delivered(toClientID: String?, messageID: String, deliveredTimestamp: Int64)
   */
  static Event3<String,String,int> OnMessageDelivered;
  /**
   * read(byClientID: String?, messageID: String, readTimestamp: Int64)
   */
  static Event3<String,String,int> OnMessageRead;
}
typedef AVIMMessageFactory = AVIMMessage Function();
typedef Event<T> = void Function(T a);
typedef Event2<A,B> = void Function(A a,B b);
typedef Event3<A,B,C> = void Function(A a,B b,C c);
typedef Event4<A,B,C,D> = void Function(A a,B b,C c,D d);
