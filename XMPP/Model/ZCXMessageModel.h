//
//  ZCXMessageModel.h
//  XMPP
//
//  Created by mac on 27/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCXMessageModel : NSObject

//  声明JID属性的目的就是：用来确认消息发送者的JID
@property (nonatomic, strong) XMPPJID *from;
//  展示消息
@property (nonatomic, copy) NSString *body;

@end

NS_ASSUME_NONNULL_END
