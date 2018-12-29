//
//  HomePageViewController.h
//  XMPP
//
//  Created by mac on 20/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomePageViewController : UIViewController

//属性传值，要把选中的那个好友JID传到会话列表中
@property (nonatomic, strong) XMPPJID *friendJID;

@end

NS_ASSUME_NONNULL_END
