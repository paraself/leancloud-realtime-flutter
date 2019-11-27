import Flutter
import UIKit
import LeanCloud

//class MessageReceiver: IMClientDelegate {
//
//    func client(_ client: IMClient, event: IMClientEvent) {
//
//    }
//
//    func client(_ client: IMClient, conversation: IMConversation, event: IMConversationEvent) {
//
//        switch event {
//        case .message(event: let messageEvent):
//            switch messageEvent {
//            case .received(message: let message):
//                print(message)
//            default:
//                break
//            }
//        default:
//            break
//        }
//    }
//}

//extension IMCategorizedMessage{
//    public func GetRawData(){
//        return self.rawData;
//    }
//}
open class CustomMessage : IMCategorizedMessage{
}

open class CustomMessage0 : CustomMessage{
    open static override var messageType: MessageType{
        return 0
    }
}
open class CustomMessage1 : CustomMessage{
    open static override var messageType: MessageType{
        return 1
    }
}
open class CustomMessage2 : CustomMessage{
    open static override var messageType: MessageType{
        return 2
    }
}
open class CustomMessage3 : CustomMessage{
    open static override var messageType: MessageType{
        return 3
    }
}
open class CustomMessage4 : CustomMessage{
    open static override var messageType: MessageType{
        return 4
    }
}
open class CustomMessage5 : CustomMessage{
    open static override var messageType: MessageType{
        return 5
    }
}
open class CustomMessage6 : CustomMessage{
    open static override var messageType: MessageType{
        return 6
    }
}
open class CustomMessage7 : CustomMessage{
    open static override var messageType: MessageType{
        return 7
    }
}
open class CustomMessage8 : CustomMessage{
    open static override var messageType: MessageType{
        return 8
    }
}
open class CustomMessage9 : CustomMessage{
    open static override var messageType: MessageType{
        return 9
    }
}
open class CustomMessage10 : CustomMessage{
    open static override var messageType: MessageType{
        return 10
    }
}



var CustomMessageTypeMap: [Int: IMCategorizedMessage.Type] = [
//    IMCategorizedMessage.ReservedType.none.rawValue: IMCategorizedMessage.self,
    IMCategorizedMessage.ReservedType.text.rawValue: IMTextMessage.self,
    IMCategorizedMessage.ReservedType.image.rawValue: IMImageMessage.self,
    IMCategorizedMessage.ReservedType.audio.rawValue: IMAudioMessage.self,
    IMCategorizedMessage.ReservedType.video.rawValue: IMVideoMessage.self,
    IMCategorizedMessage.ReservedType.location.rawValue: IMLocationMessage.self,
    IMCategorizedMessage.ReservedType.file.rawValue: IMFileMessage.self,
    IMCategorizedMessage.ReservedType.recalled.rawValue: IMRecalledMessage.self,
    0:CustomMessage0.self,
    1:CustomMessage1.self,
    2:CustomMessage2.self,
    3:CustomMessage3.self,
    4:CustomMessage4.self,
    5:CustomMessage5.self,
    6:CustomMessage6.self,
    7:CustomMessage7.self,
    8:CustomMessage8.self,
    9:CustomMessage9.self,
    10:CustomMessage10.self,
]


extension IMMessage.PatchedReason{
    public func toMap()->[String: Any]{
        return [
            "code":self.code,
            "reason":self.reason,
        ]
    }
}

extension IMConversation{
    public func toMap()->[String: Any]{
        return [
            "attributes":self.attributes,
            "conversationId":self.ID,
            "creator":self.creator,
            "lastMessage":self.lastMessage?.toMap(),
            "memberIds":self.members,
            "name":self.name,
            "isMuted":self.isMuted,
            "unreadMessageCount":self.unreadMessageCount
        ]
    }
}

extension IMConversation.MessageQueryEndpoint
{
    init(parameters:[String: Any]) {
        self.isClosed = parameters["isClosed"] as? Bool
        self.messageID = parameters["messageID"] as? String
        self.sentTimestamp = parameters["sentTimestamp"] as? Int64
    }
}
extension LCFile{
    public convenience init(data:[String: Any] ){
        var filePath = data["filePath"] as? String
        if(filePath != nil){
            self.init(payload: Payload.fileURL(fileURL: URL(fileURLWithPath: filePath!)))
        }
        else if(data["data"] != nil){
            var bytes = (data["data"] as! FlutterStandardTypedData).data
            self.init(payload: Payload.data(data: bytes))
        }
        else{
            self.init()
        }
        self.name = (data["name"] as? String)?.lcString
        self.url = (data["url"] as? String)?.lcString
        if(data["metaData"] != nil){
            self.metaData = LCDictionary((data["metaData"] as! [String: String]))
        }
    }
    public func toMap()->[String: Any]{
        return [
            "url":self.url?.stringValue,
            "name":self.name?.stringValue,
            "metaData":self.metaData?.rawValue
        ]
    }
    
    public func fromMap(data:[String: Any] ){
    }
}
extension IMMessage{
    
    public func fromMap(data:[String: Any] ){
        self.isAllMembersMentioned = data["isAllMembersMentioned"] as? Bool
        self.mentionedMembers = data["mentionedMembers"] as? [String]
        
        if(self is IMCategorizedMessage){
            let message = self as! IMCategorizedMessage
            message.text = data["text"] as? String
            message.attributes = data["text"] as? [String : Any]
            
            if(data["file"] != nil){
                message.file = LCFile( data: (data["file"] as! [String: Any]))
            }

            if(data["rawData"] != nil){
                var rawData = data["rawData"] as! [String: Any]
                for var e in rawData {
                    message[e.key] = e.value
                }
            }
        }
    }
    
    public func toMap()->[String: Any]{
        var data:[String: Any] = [:]
        data["content"] = self.content?.string
        data["conversationId"] = self.conversationID
        data["fromClientId"] = self.fromClientID
        data["id"] = self.ID
//        if(self.content != nil){
//            switch self.content {
//            case .data(data:let contentData):
//                data["messageBody"] = contentData.base64EncodedString();
//            case .string(String : let text):
//                data["messageBody"] = text
//            case .none:
//                break;
//            }
//        }
        data["messageStatus"] = self.status.rawValue
        data["readTimestamp"] = self.readTimestamp
        data["sentTimestamp"] = self.sentTimestamp
        data["deliveredTimestamp"] = self.deliveredTimestamp
        
        data["isAllMembersMentioned"] = self.isAllMembersMentioned
        data["mentionedMembers"] = self.mentionedMembers
        data["isCurrentClientMentioned"] = self.isCurrentClientMentioned
        if( self is IMCategorizedMessage){
            let messageCategorizing = self as! IMCategorizedMessage
            data["text"] = messageCategorizing.text
            data["attributes"] = messageCategorizing.attributes
            data["file"] = messageCategorizing.file?.toMap()
            
            var reservedType:Int? = nil;
            switch messageCategorizing {
            case is IMTextMessage:
                reservedType = IMTextMessage.messageType;
            case is IMImageMessage:
                reservedType = IMImageMessage.messageType;
            case is IMAudioMessage:
                reservedType = IMAudioMessage.messageType;
            case is IMVideoMessage:
                reservedType = IMVideoMessage.messageType;
            case is IMLocationMessage:
                reservedType = IMLocationMessage.messageType;
            case is IMFileMessage:
                reservedType = IMFileMessage.messageType;
            default:
                break
            }
            if(reservedType != nil ){
                data["mediaType"] = reservedType
            }
        }
        return data
    }
}

public class SwiftLeancloudRealtimeFlutterPlugin: NSObject, FlutterPlugin, IMClientDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "leancloud_realtime_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftLeancloudRealtimeFlutterPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
    static func CreateMessage(params:[String:Any]){
        var message = IMMessage.init()
//        message.ID = params["id"] as? String
//        message.sentTimestamp = params["sentTimestamp"] as? int
    }
    var client : IMClient!;
    var channel : FlutterMethodChannel!;
    
    func registerCustomMessage( mediaType : Int){
        do {
            try CustomMessageTypeMap[mediaType]!.register()
        } catch {
            print(error)
        }
    }
    
//    func OnMessageReceive(_ client: IMClient, conversation: IMConversation, event: IMConversationEvent) {
//        switch event {
//        case .message(event: let messageEvent):
//            switch messageEvent {
//            case .received(message: let message):
//                print(message)
//            default:
//                break
//            }
//        default:
//            break
//        }
//    }
    
    public func client(_ client: IMClient, event: IMClientEvent) {
        print("client(_ client: IMClient, event: IMClientEvent)")
    }
    
    public func client(_ client: IMClient, conversation: IMConversation, event: IMConversationEvent) {
        print("client(_ client: IMClient, conversation: IMConversation, event: IMConversationEvent)")
        print(event)
        switch event {
        case .message(event: let messageEvent):
            switch messageEvent {
            case .received(message: let message):
                self.channel.invokeMethod("OnMessageReceived",arguments: message.toMap() as Any)
                break
            case .updated(updatedMessage: let updatedMessage, reason : let reason): self.channel.invokeMethod("OnMessageUpdated",arguments:[updatedMessage.toMap() as Any, reason?.toMap() as Any])
            break
            case .delivered(toClientID: let toClientID, messageID : let messageID, deliveredTimestamp : let deliveredTimestamp): self.channel.invokeMethod("OnMessageDelivered",arguments:[toClientID as Any, messageID as Any,deliveredTimestamp as Any])
            break
            case .read(byClientID: let byClientID, messageID: let messageID, readTimestamp: let readTimestamp): self.channel.invokeMethod("OnMessageRead",arguments:[byClientID as Any, messageID as Any,readTimestamp as Any])
            break
            }
        default:
            print("unknown message")
            break
        }
    }
    
    func createFlutterError(error:Any) -> FlutterError{
        let message = String(describing:error)
        return FlutterError.init(code: "Error",message:message ,details: nil )
    }
    
    func CreateClient(user:LCUser, result: @escaping FlutterResult) {
        do{
            let options: IMClient.Options = { var dOptions = IMClient.Options.default; dOptions.remove(.usingLocalStorage); return dOptions }()
            self.client = try IMClient(
                user: user,
                tag: "mobile",
                options:options,
                delegate:self
            )
            
            self.client.open(completion: { (__result) in
                print("client.open")
                result("")
                // 执行其他逻辑
            })
        }catch {
            print(error)
            result(self.createFlutterError(error: error))
        }
    }
    
    func become( sessionToken: String, result: @escaping FlutterResult){
        if(self.lastSessionToken == sessionToken){
            result("")
            return
        }
        LCUser.logOut()
        LCUser.logIn(sessionToken: sessionToken){ (_result) in
            switch _result {
            case .success(object: let user):
                self.lastSessionToken = sessionToken
                if(self.client != nil){
                    self.client!.close(){(completion) in
                        self.CreateClient(user:user,result:result)
                    }
                }else{
                    self.CreateClient(user:user,result:result)
                }
            case .failure(error: let error):
                print(error)
                result(self.createFlutterError(error: error))
            }
        }
    }
    
    func getConversations(IDs: [String], result: @escaping FlutterResult){
        do {
            try self.client.conversationQuery.getConversations(by: Set<String>( IDs)) { (lcResult) in
                result(lcResult.value?.map{ $0.toMap() })
            }
        } catch {
            print(error)
            result(createFlutterError(error: error))
        }
        
    }
    
    func CreateConversation( params:[String: Any], result: @escaping FlutterResult){
        do {
            try self.client.createConversation(clientIDs: Set(params["clientIDs"] as! [String]), name: params["name"] as? String,
                   attributes: params["attributes"] as? [String: Any],
                   isUnique: params["isUnique"] as? Bool ?? true){(_result)in
                    if(_result.isFailure){
                        result(_result.error)
                        return
                    }
                    result(_result.value?.toMap())
            }
        }  catch {
                   print(error)
            result(createFlutterError(error: error))
               }
        
    }
    
    func QueryMessage( params:[String: Any], result: @escaping FlutterResult) {
        do {
            let id = params["conversationId"] as! String
            try self.client.getCachedConversation(ID: id){(conversation) in
                if(conversation.isFailure){
                    result(conversation.error)
                    return
                }
                var start:IMConversation.MessageQueryEndpoint?
                if(params["start"] != nil){
                    start = IMConversation.MessageQueryEndpoint(parameters: params["start"] as! [String:Any])
                }
                
                var end:IMConversation.MessageQueryEndpoint?
                if(params["end"] != nil){
                    end = IMConversation.MessageQueryEndpoint(parameters: params["end"] as! [String:Any])
                }
                
                
                var direction :IMConversation.MessageQueryDirection?
                if(params["direction"] != nil ){
                    direction = IMConversation.MessageQueryDirection.init( rawValue: params["direction"] as! Int)
                }
                do{
                    try conversation.value!.queryMessage(
                    start:start,
                    end:end,
                    direction:direction,
                    limit: params["limit"] as? Int ?? 100,
                    type: params["type"] as? Int){(messages) in
                        if(messages.isFailure){
                            result(messages.error)
                            return
                        }
                        result(messages.value!.map{$0.toMap()})
                    }
                } catch {
                           print(error)
                    result(self.createFlutterError(error: error))
                       }
                
            }
        } catch {
            print(error)
            result(createFlutterError(error: error))
        }
        
    }
    
    func ConversationRead(id:String, result: @escaping FlutterResult){
        
        do {
            try self.client.getCachedConversation(ID: id){(conversation) in
                if(conversation.isFailure){
                    result(conversation.error)
                    return
                }
                conversation.value!.read()
                result("")
            }
        }catch {
            print(error)
            result(createFlutterError(error: error))
        }
    }
    
    func ConversationSendText(id:String,text:String, result: @escaping FlutterResult){
        
        do {
            try self.client.getCachedConversation(ID: id){(conversation) in
                if(conversation.isFailure){
                    result(self.createFlutterError(error: conversation.error))
                    return
                }
                do {
                 try conversation.value!.send(message: IMTextMessage(text: text)){
                        (_result)in
                            if(_result.isFailure){
                                result(_result.error)
                            return
                        }
                    result(_result.isSuccess)
                    }
                }catch {
                    print(error)
                    result(error)
                }
            }
        }catch {
            print(error)
            result(createFlutterError(error: error))
        }
    }
    
    func ConversationSendMessage(params:[String: Any],result: @escaping FlutterResult){
        print("ConversationSendMessage")
        let mediaType = params["mediaType"] as! Int
        let conversationId = params["conversationId"] as! String
        let message = params["message"] as! [String: Any]
        let pushData = params["pushData"] as? [String: Any]
        let progressId = params["progress"]
        
        var progress:((Double) -> Void)? = nil
        if(progressId != nil){
            progress = {(p)in
                self.channel.invokeMethod("OnProgressCallback",arguments: [progressId,p])
            }
        }
        do {
            try self.client.getCachedConversation(ID: conversationId){(conversation) in
                if(conversation.isFailure){
                    result(self.createFlutterError(error: conversation.error))
                    return
                }
                do {
                    var message = CustomMessageTypeMap[mediaType]!.init()
                    message.fromMap(data: params["message"] as! [String : Any])
                    try conversation.value!.send(message: message,pushData:pushData,progress:progress){
                        (_result)in
                        print("conversation.value!.send completed")
                            if(_result.isFailure){
                                result(_result.error)
                            return
                            }
                        result(message.toMap())
                    }
                }catch {
                    print(error)
                    result(error)
                }
            }
        }catch {
            print(error)
            result(createFlutterError(error: error))
        }
    }
     var lastSessionToken:String? = nil
 public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch(call.method){
    case "getPlatformVersion":do {
            result("iOS " + UIDevice.current.systemVersion)
            return
        }
    case "Init":do {

            let args = call.arguments as! [String: Any]
            LCApplication.logLevel = .all
            do {
                try LCApplication.default.set(
                    id: args["id"] as! String,
                    key: args["key"] as! String,
                    serverURL: args["serverURL"] as! String)
                result("")
            } catch {
                print(error)
                result(createFlutterError(error: error))
            }
            return
        }
    case "become":do {
        become(sessionToken: call.arguments as! String,result: result)
        return
        }
    case "close":do {
        if(self.client != nil){
            self.client!.close(){(completion) in
                result("")
            }
            self.client = nil
        }else{
            result("")
        }
        LCUser.logOut()
        self.lastSessionToken = nil
        return
        }
    case "registerCustomMessage":do {
        self.registerCustomMessage(mediaType: call.arguments as! Int)
        return
        }
    default:
        break;
    }
    
    if(self.client == nil){
        print("client is nil")
        result(createFlutterError(error: "client is nil"));
        return;
    }
    switch(call.method){
    case "getConversations":do{
        self.getConversations(IDs: call.arguments as! [String], result:result)
        break
        }
    case "QueryMessage":do{
        self.QueryMessage(params: call.arguments as! [String:Any], result:result)
        }
    case "ConversationRead":do{
        self.ConversationRead( id:call.arguments as! String, result:result)
        }
    case "ConversationSendText":do{
        let args = call.arguments as! [String]
        self.ConversationSendText( id:args[0],text: args[1], result:result)
        }
    case "CreateConversation":do{
        self.CreateConversation(params: call.arguments as! [String:Any], result: result )
        }
    case "ConversationSendMessage":do{
        self.ConversationSendMessage(params: call.arguments as! [String:Any], result: result )
        }
        
    default:
        print("unknown method "+call.method)
        result(createFlutterError(error: "unknown method"));
    }
    }
}
