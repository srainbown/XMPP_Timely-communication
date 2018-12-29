//
//  ZCXTool.m
//  XMPP
//
//  Created by mac on 26/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import "ZCXTool.h"
#import "MBProgressHUD.h"
@implementation ZCXTool

+(void)showErrorMBProgressHUDtoView:(UIView *)view andText:(NSString *)text andDelay:(NSInteger)delay{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:view];
    [view addSubview:hud];
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.color = [UIColor blackColor];
    hud.label.text = text;
    hud.label.textColor = [UIColor whiteColor];
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:delay];
    
}

@end
