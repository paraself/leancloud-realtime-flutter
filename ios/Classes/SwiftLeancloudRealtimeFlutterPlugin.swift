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
    public static var _messageType: MessageType = 0;
    open class override var messageType: MessageType{
        return _messageType;
    }
}


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
extension IMMessage{
    
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
            data["url"] = messageCategorizing.file?.url?.stringValue
            
            var reservedType:Int = 0;
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
            data["mediaType"] = reservedType
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
        CustomMessage._messageType = mediaType
        do {
            try CustomMessage.register()
        } catch {
            print(error)
        }
    }
    
    func OnMessageReceive(_ client: IMClient, conversation: IMConversation, event: IMConversationEvent) {
        switch event {
        case .message(event: let messageEvent):
            switch messageEvent {
            case .received(message: let message):
                print(message)
            default:
                break
            }
        default:
            break
        }
    }
    
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
    
    func become( sessionToken: String, result: @escaping FlutterResult){

        LCUser.logIn(sessionToken: sessionToken){ (_result) in
            switch _result {
            case .success(object: let user):
                do {
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
                } catch {
                    print(error)
                    result(error)
                }
            case .failure(error: let error):
                print(error)
                result(error)
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
            result(error)
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
                   result(error)
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
                           result(error)
                       }
                
            }
        } catch {
            print(error)
            result(error)
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
            }
            result(nil)
        }catch {
            print(error)
            result(error)
        }
    }
    
    func ConversationSendText(id:String,text:String, result: @escaping FlutterResult){
        
        do {
            try self.client.getCachedConversation(ID: id){(conversation) in
                if(conversation.isFailure){
                    result(conversation.error)
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
            result(nil)
        }catch {
            print(error)
            result(error)
        }
    }
    
 public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch(call.method){
    case "getPlatformVersion":do {
            result("iOS " + UIDevice.current.systemVersion)
            break
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
                result(error)
            }
            break
        }
    case "become":do {
        become(sessionToken: call.arguments as! String,result: result)
        break
        }
    case "registerCustomMessage":do {
        self.registerCustomMessage(mediaType: call.arguments as! Int)
        break
        }
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
        
    default:
        print("unknown method "+call.method)
        result(nil);
    }
    }
}
