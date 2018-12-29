//
//  ZCXXMPPManager.m
//  XMPP
//
//  Created by mac on 26/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//
//登录需要用到账号，即用户唯一标识符（JID）
//JID一般由三部分组成：用户名，域名和资源名。格式为user@domain/resource,例如test@example.com/Anthony。对应XMPPJID中的三个属性：user，domain,resource。
//如果没有设置主机名(host),则使用JID的域名（domain）作为主机名，而端口号是可选的，默认为5222，一般也没有必要改动。
//    self.xmppStream.myJID = [XMPPJID jidWithString:@"user@gami.com"];
//    stream.hostName = @"myCompany.com";
//    stream.hostPort = @"192.168.2.27";

//设置代理和移除代理
//    [stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [stream removeDelegate:self];

//管理用户在线状态
//    stream.myPresence

//消息查询（IQ）IQ是一种请求/相应机制，从1个实体发送请求，另外1个实体接受请求并进行响应。例如，client在stream的d上下文中插入一个元素，向server请求得到自己的好友列表，server反回1个，里面是请求结果。
//    XMPPIQ

#import "ZCXXMPPManager.h"

@interface ZCXXMPPManager()

@property (nonatomic, strong) NSMutableArray *friendArray;

@property (nonatomic, copy) NSString *password;

@end

@implementation ZCXXMPPManager

+(ZCXXMPPManager *)sharedInstance{
    static ZCXXMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZCXXMPPManager alloc]init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //初始化
        self.xmppStream = [[XMPPStream alloc]init];
        self.xmppStream.hostName = KHostName;
        self.xmppStream.hostPort = KHostPort;
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //花名册
        XMPPRosterCoreDataStorage *rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:rosterCoreDataStorage];
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.xmppRoster activate:self.xmppStream];
        
        //消息
        XMPPMessageArchivingCoreDataStorage *messageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messageArchivingCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活收发信息的观察
        [self.xmppMessageArchiving activate:self.xmppStream];
        //创建数据管理器
        self.context = messageArchivingCoreDataStorage.mainThreadManagedObjectContext;
        
        
    }
    return self;
}
#pragma mark -- 连接服务器
- (void)connectToServerWithUserName:(NSString *)userName{
    //设置连接双方IP和账号
    XMPPJID *xmppJid = [XMPPJID jidWithUser:userName domain:KDomin resource:KResource];
    self.xmppStream.myJID = xmppJid;
    
    //先断开再连接（如果当前是连接状态，再次连接会崩溃）
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        //发送下线状态
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [self.xmppStream sendElement:presence];
        //断开连接
        [self.xmppStream disconnect];
    }
    
    //连接服务器
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:-1 error:&error];
    if (error) {
        NSLog(@"连接出错:%@",[error localizedDescription]);
    }
}
#pragma mark -- 登录
- (void)loginWithUserName:(NSString *)userName withPassword:(NSString *)password{
    self.connectToServerPurpose = ConnectToServerPurposeLogin;
    self.password = password;
    [self connectToServerWithUserName:userName];
}

#pragma mark -- 注册
- (void)registerWithUserName:(NSString *)userName withPassword:(NSString *)password{
    self.connectToServerPurpose = ConnectToServerPurposeRegister;
    self.password = password;
    [self connectToServerWithUserName:userName];
}

#pragma mark -- 添加好友
- (void)addFriendActionWithFriendName:(NSString *)friendName{
    
}


#pragma mark -- XMPPStreamDelegate
//连接回调
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"连接成功");
    if (self.connectToServerPurpose == ConnectToServerPurposeRegister) {
        //注册
        [self.xmppStream registerWithPassword:@"123456" error:nil];
    }
    if (self.connectToServerPurpose == ConnectToServerPurposeLogin) {
        //登录
        [self.xmppStream authenticateWithPassword:@"123456" error:nil];
    }
}
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"连接超时");
}

//注册回调
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    if (self.registerResultBlock) {
        self.registerResultBlock(@"注册成功");
    }
    NSLog(@"注册成功");
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    if (self.registerResultBlock) {
        self.registerResultBlock(@"注册失败");
    }
    NSLog(@"注册失败");
}

//登录回调
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    if (self.loginResultBlock) {
        self.loginResultBlock(@"登录成功");
    }
    NSLog(@"登录成功");
    //发送上线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:presence];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    if (self.loginResultBlock) {
        self.loginResultBlock(@"登录失败");
    }
    NSLog(@"登录失败:%@",error);
}

//发送接收消息的回调
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    if(self.didSendMessageBlock){
        self.didSendMessageBlock(message);
    }
    NSLog(@"发送了消息");
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    if (self.didReceiveMessageBlock) {
        self.didReceiveMessageBlock(message);
    }
    NSLog(@"接收了消息");
//    XMPPJID *jid = message.from;
}

#pragma mark -- XMPPRosterDelegate
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version{
    NSLog(@"开始检索");
}
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{
    NSLog(@"检索到好友");
    //获取节点的属性
    //subscription:订阅的意思。
    //both:两人互为好友。
    //to:我订阅比人，别人未订阅我。
    //from:别人订阅我，我未订阅别人。
    //要展示好友列表，所以找both的item。
    NSString *subscriptionValue = [[item attributeForName:@"subscription"]stringValue];
    //展示互为好友信息
    if([subscriptionValue isEqualToString:@"both"]){
        NSString *jidStr = [[item attributeForName:@"jid"]stringValue];
        XMPPJID *friendjid = [XMPPJID jidWithString:jidStr];
        //如果数组中已经存在该好友对象，就不再添加
        if ([self.friendArray containsObject:friendjid]) {
            return;
        }
        //添加到数组中
        [self.friendArray addObject:friendjid];
    }
    //刷线列表
}
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"结束检索");
}
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"接收到添加好友请求");
    //同意
    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
    //拒绝
    //    [self.xmppRoster rejectPresenceSubscriptionRequestFrom:presence.from];
}

@end
