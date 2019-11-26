import 'package:leancloud_realtime_flutter/AVIMMessage.dart';
import 'package:leancloud_realtime_flutter/Message.dart';
import 'package:leancloud_realtime_flutter/LeancloudRealtime.dart';

enum MessageQueryDirection{
  newToOld ,
  oldToNew
}

class AVIMConversation{
  AVIMConversation({this.conversationId});
  decoding(Map<String, dynamic> data){
    if(data['attributes']!=null){
      this.attributes = data['attributes'].map((a, b) => MapEntry(a as String, b));
    }
    this.creator = data['creator'];
    if(data['memberIds']!=null)
    this.memberIds = (data['memberIds'] as List<dynamic>).map((e)=>e as String).toList();
    this.name = data['name'];
    this.isMuted = data['isMuted'];
    this.lastMessage= data['lastMessage'];
    this.unreadMessageCount = data['unreadMessageCount'];
  }
  /**
   * 对话的自定义属性
   */
  Map<String, dynamic> attributes ;

  /**
   * 对话的唯一ID
   */
  final String conversationId ;

  /**
   * 对话的创建者
   */
  String creator ;

  // /**
  //  * 是否为聊天室
  //  */
  // String isTransient ;

  // /**
  //  * 对话最后活跃的时间，也可以理解为最近的一条消息发送或者接受的时间
  //  */
  // String lastMesaageAt ;

  /**
   *  The last message of the conversation.
  */ 
  AVIMTypedMessage lastMessage;

  /**
   * 对话中存在的 Client 的 Id 列表
   */
  List<String> memberIds ;

  /**
  //  * 对该对话静音的成员列表
  //   * Remarks
  //   * 对该对话设置了静音的成员，将不会收到离线消息的推送。
  //  */
  // List<String> muteMemberIds ;

  /**
   * 对话在全局的唯一的名字
   */
  String name ;

  /**
   * Indicates whether the conversation has been muted.
   */
  bool isMuted;

/**
 * The unread message count of the conversation
 */
  int unreadMessageCount;

  /**
   * 批量添加成员，添加其他的成员到当前对话中。
   */
  Future<bool> AddMembersAsync(List<String> clientIds)async{

  }
  /**
   * 单个添加成员到当前对话，如果要添加当前 Current Client，请调用JoinAsync
   */
  Future<bool> AddMemberAsync(String clientId)async{

  }
  /**
   * 获取服务端准确的成员数量
   */
  Future<int> CountMembersAsync()async{

  }
  /**
   * 从服务端加载数据到本地
   */
  Future FetchAsync()async{

  }
  /**
   * 当前 Client 加入当前对话
   */
  Future<bool> JoinAsync()async{

  }
  /**
   * 当前 Client 退出当前对话。
   */
  Future<bool>  LeftAsync()async{

  }
  /**
   * 当前 Client 对该对话设置静音
   */
  Future MuteAsync()async{

  }

  // /**
  //  * 在终端用户进入一个对话的时候，最常见的需求就是由新到旧、以翻页的方式拉取并展示历史消息
  //  * limit 取值范围 1~1000，默认 100
  //  */
  // Future<List<AVIMMessage>> QueryHistory({
  //       int limit = 100}){
  // }
  /**
   * LeanCloud 即时通讯云端通过消息的 messageId 和发送时间戳来唯一定位一条消息，因此要从某条消息起拉取后续的 N 条记录，只需要指定起始消息的 messageId 和发送时间戳作为锚定就可以了
   * limit 取值范围 1~1000，默认 100
   * 
    /// - Parameters:
    ///   - start: start endpoint, @see `MessageQueryEndpoint`.
    ///   - end: end endpoint, @see `MessageQueryEndpoint`.
    ///   - direction: @see `MessageQueryDirection`. default is `MessageQueryDirection.newToOld`.
    ///   - limit: The limit of the query result, should in range `limitRangeOfMessageQuery`. default is 20.
    ///   - type: @see `IMMessageCategorizing.MessageType`.
   */
  Future<List<AVIMTypedMessage>> QueryMessage({
        MessageQueryEndpoint start,
        MessageQueryEndpoint end,
        MessageQueryDirection direction,
        int limit,
        int mediaType,
        // policy: MessageQueryPolicy = .default,
        }){
          var params = new Map<String,dynamic>();
          if(start!=null){
            params["start"] = start.encoding();
          }
          if(end!=null){
            params["end"] = end.encoding();
          }
          if(direction!=null){
            if(direction==MessageQueryDirection.newToOld ){
              params["direction"] = 1;
            }
            else if(direction==MessageQueryDirection.oldToNew ){
              params["direction"] = 2;
            }
          }
            params["limit"] = limit;
            params["mediaType"] = mediaType;
            return  LeancloudRealtime.QueryMessage(this, params);
  }

  /**
   * 批量地从当前对话中删除成员。
   */
  Future<bool> RemoveMembersAsync(List<String> clientIds)async{

  }
  /**
   * 删除单个成员。
   */
  Future<bool> RemoveMemberAsync(String clientId)async{

  }
  /**
   * 保存对话，并且在服务端生效
   */
  Future SaveAsync()async{

  }
  Future<bool> Send(AVIMTypedMessage message)async{

  }
  // /**
  //  * 发送音频消息
  //  */
  // Future<bool> SendAudioMessageAsync(AVIMAudioMessage avAudioMessage)async{

  // }
  // /**
  //  * 发送文件消息
  //  */
  // Future<bool> SendFileMessageAsync(AVIMFileMessage avFileMessage)async{

  // }
  // /**
  //  * 发送图片消息
  //  */
  // Future<bool> SendImageMessageAsync(AVIMImageMessage avImageMessage)async{

  // }
  // /**
  //  * 发送视频消息
  //  */
  // Future<bool> SendVideoMessageAsync(AVIMVideoMessage avVideoMessage)async{

  // }
  // /**
  //  * 发送富媒体消息
  //  */
  // Future<bool> SendTypedMessageAsync(AVIMTypedMessage avTypedMessage)async{

  // }
  // /**
  //  * 向该对话发送消息。
  //  */
  // Future<bool> SendMessageAsync(AVIMMessage avMessage)async{

  // }
  /**
   * 向该对话发送普通的文本消息。
   * textContent
    * 文本消息的内容，一般就是一个不超过5KB的字符串。
    * transient
    * 是否暂态消息，true则表示只有在线才能收到，false表示如果对方不在线，则会收到离线推送。
    * receipt
    * 是否需要回执，此字段是相对于 transient 在为 fasle 时候,并且对方上线之后，而且对方收到了这条信息，在发送方这端就会触发OnMessageDeliverd
   */
  Future SendTextMessageAsync(String text)async{
    return LeancloudRealtime.ConversationSendText(this, text);
  }
  
  void SetAttribute(
    String key,
    dynamic value){

  }
  /**
   * 当前 Client 取消针对该对话的静音操作，重新接受消息。
   */
  Future UnmuteAsync() async{

  }

  /**
   * Clear unread messages that its sent timestamp less than the sent timestamp of the parameter message.
   */
  void read() async{
    LeancloudRealtime.ConversationRead(this);
  }
}