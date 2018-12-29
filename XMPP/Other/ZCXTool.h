//
//  ZCXTool.h
//  XMPP
//
//  Created by mac on 26/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCXTool : NSObject

+(void)showErrorMBProgressHUDtoView:(UIView *)view andText:(NSString *)text andDelay:(NSInteger)delay;
    
@end

NS_ASSUME_NONNULL_END
