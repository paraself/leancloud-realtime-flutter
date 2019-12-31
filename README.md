leancloud 的 即时消息 flutter 插件 leancloud_realtime_flutter
当前仅支持了ios版本

# 初始化
```dart
    LeancloudRealtime.Init(
                id: "your leancloud id",
                key: "your leancloud id",
                serverURL: "https://leancloud.cn"
      );
```
# 消息回调
```dart
    //收到消息的回调
    LeancloudRealtime.OnMessageReceived = OnMessageReceived;
  OnMessageReceived(AVIMMessage message){
    print( message.text) ;
    if(message is AVIMFileMessageBase){
      print( message.url) ;
    }
  }
```
# 登入
```dart
    //用session token 登入
    await LeancloudRealtime.become("ivdct9mt0c0sfg9nho23n1ox7");
```
# 登出
```dart
    //用session token 登入
    await LeancloudRealtime.close();
```

# 注册自定义消息
```dart
    //注册自定义消息
    LeancloudRealtime.registerCustomMessage(1,()=>new MyMessageType());

class MyMessageType extends AVIMMessage{
  MyMessageType({String value}):super(mediaType:1){
    customField = value;
  }
//设置自定义内容
  void set customField (String value){
    rawData["customField"] = value;
  }
//读取自定义内容
  String get customField{
    return rawData["customField"];
  }
}
```

# 创建对话
```dart
    // 第一个参数为除了自己以外,要拉入对话的人的id
    var conversation = await LeancloudRealtime.CreateConversation(["5ddb2c15844bb4008874ec3b"],name: "测试");
    print(conversation.conversationId);
    // 发送文本消息
    await conversation.SendTextMessageAsync('test 1');
```

# 发送文件消息
```dart
  TestSendImage()async {
    //创建对话,默认 isUnique为真
    print("TestSendImage");
    var imageMessage = new AVIMImageMessage(filePath:_imgPath.path );
    var conversation = await LeancloudRealtime.CreateConversation(["5ddb2c15844bb4008874ec3b"],name: "测试");
    print(conversation.conversationId);
    // 发送文本消息 , progress为进度回调
    await conversation.Send(imageMessage, progress: (f)=> print(f));
    print("TestSendImage Finish");
    print(imageMessage.toString());
  }
```
其他类型消息,选择对应的文件消息类发送


# 拉取消息
```dart
  TestConversation( List IDs)async {
    //获取消息所在的 Conversation, 这里只拿返回的第一个做测试
    var result = (await LeancloudRealtime.getConversations(IDs))[0];
    //log出未读消息数量
    print(result.conversationId+' unreadMessageCount '+result.unreadMessageCount.toString());
    
    //将消息标记为已读
    result.read();

    //获取历史消息
    var messages = await result.QueryMessage();
    // var messages = await result.QueryMessage(limit: 10,start: new MessageQueryEndpoint(sentTimestamp:1574627527681, messageID: "6wXN4JBgoxqHA6SakWAnmz" ));
    // print(messages);
    print(messages.map((f)=> jsonEncode(f.rawData) ));
  }
```