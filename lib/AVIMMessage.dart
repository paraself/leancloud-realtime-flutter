



// class AVIMMessageIOType{
//   /**
//    * 收到的消息
//    */
//   static final AVIMMessageIOTypeIn = 1;
//   /**
//    * 	发送的消息
//    */
//   static final AVIMMessageIOTypeOut = 2;
// }

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

// class AVIMMessageStatus{
//   /**
//    * 
//    */
// 	static final AVIMMessageStatusNone	= 0	;
//   /**
//    * 正在发送
//    */
// 	static final AVIMMessageStatusSending	= 1	;
//   /**
//    * 已发送
//    */
// 	static final AVIMMessageStatusSent	= 2	;
//   /**
//    * 已送达
//    */
// 	static final AVIMMessageStatusDelivered	= 3	;
//   /**
//    * 失败
//    */
// 	static final AVIMMessageStatusFailed	= 4	;
// }


/// Message IO Type.
enum AVIMMessageIOType {
  isIn,
  isOut,
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

class AVIMMessage{


  // static AVIMMessageIOType IntToIOType(int code){
  //   switch(code){
  //     case 1: return AVIMMessageIOType.isIn;
  //     case 2: return AVIMMessageIOType.isOut;
  //   }
  // }

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
   * 消息的原始数据
   */
  Map<String, dynamic> rawData;

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

  // /**
  //  * 实际发送的消息体
  //  */
  // String messageBody;

  /**
   * 消息的状态 - AVIMMessageStatus
   */
  AVIMMessageStatus messageStatus;

  // /**
  //  * 消息的来源类型 - AVIMMessageIOType
  //  */
  // AVIMMessageIOType get  messageIOType {
  //   // if(fromClientId==)
  // }

  // /**
  //  * 是否需要回执
  //  */
  // bool receipt;

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

}