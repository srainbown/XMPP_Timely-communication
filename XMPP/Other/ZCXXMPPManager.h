//
//  ZCXXMPPManager.h
//  XMPP
//
//  Created by mac on 26/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>

NS_ASSUME_NONNULL_BEGIN

//枚举，用于区别登陆还是注册
//用ConnectToServerPurpose类型 去代替 NSInteger类型
typedef NS_ENUM(NSInteger , ConnectToServerPurpose) {
    //枚举值
    ConnectToServerPurposeLogin ,
    ConnectToServerPurposeRegister
};

typedef void(^LoginResultBlock)(NSString *);
typedef void(^RegisterResultBlock)(NSString *);
typedef void(^DidSendMessageBlock)(XMPPMessage *);
typedef void(^DidReceiveMessageBlock)(XMPPMessage *);


@interface ZCXXMPPManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate>

@property (nonatomic,copy) LoginResultBlock loginResultBlock;
@property (nonatomic,copy) RegisterResultBlock registerResultBlock;
@property (nonatomic,copy) DidSendMessageBlock didSendMessageBlock;
@property (nonatomic,copy) DidReceiveMessageBlock didReceiveMessageBlock;

//@property (nonatomic,strong)NSString *password;
//将枚举设成属性
@property (nonatomic,assign) ConnectToServerPurpose connectToServerPurpose;

//数据流
@property (nonatomic, strong) XMPPStream *xmppStream;
//重新连接
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
//花名册
@property (nonatomic, strong) XMPPRoster *xmppRoster;
//信息归档对象
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;
//数据管理器
@property (nonatomic,strong)NSManagedObjectContext *context;

+(ZCXXMPPManager *)sharedInstance;

//连接通讯通道
- (void)connectToServerWithUserName:(NSString *)userName;

//登录
- (void)loginWithUserName:(NSString *)userName withPassword:(NSString *)password;

//注册
- (void)registerWithUserName:(NSString *)userName withPassword:(NSString *)password;

//添加好友
- (void)addFriendActionWithFriendName:(NSString *)friendName;


@end

NS_ASSUME_NONNULL_END
