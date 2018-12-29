//
//  ZCXLoginViewController.m
//  XMPP
//
//  Created by mac on 26/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import "ZCXLoginViewController.h"
#import "ZCXRegisterViewController.h"
#import "ZCXXMPPManager.h"
#import "HomePageViewController.h"

@interface ZCXLoginViewController ()

@property (nonatomic, strong) ZCXXMPPManager *manager;
@property (nonatomic, strong) UIImageView *bgImage;
@property (nonatomic, strong) UITextField *userNameTF;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UIButton *logInBtn;
@property (nonatomic, strong) UIButton *registerBtn;

@end

@implementation ZCXLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"登陆";

    self.manager = [ZCXXMPPManager sharedInstance];
    [self createUI];
}

#pragma mark -- UI
-(void)createUI{
    //背景视图
    _bgImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_bgImage];
    _bgImage.image = [UIImage imageNamed:@"login_bg"];
    _bgImage.userInteractionEnabled = YES;
    
    //输入账号
    _userNameTF = [[UITextField alloc]init];
    [_bgImage addSubview:_userNameTF];
    [_userNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(150*ZCXWidthScale);
        make.centerX.mas_equalTo(self.bgImage);
        make.width.mas_equalTo(290*ZCXWidthScale);
        make.height.mas_equalTo(45*ZCXWidthScale);
    }];
    [self createTF:_userNameTF andImage:@"register-icon-user-n" andPlaceholder:@"请输入账号"];
    _userNameTF.keyboardType = UIKeyboardTypeASCIICapable;
    
    //输入密码
    _passwordTF = [[UITextField alloc]init];
    [_bgImage addSubview:_passwordTF];
    [_passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userNameTF.mas_bottom).offset(20*ZCXWidthScale);
        make.centerX.mas_equalTo(self.bgImage);
        make.width.mas_equalTo(290*ZCXWidthScale);
        make.height.mas_equalTo(45*ZCXWidthScale);
    }];
    _passwordTF.secureTextEntry = YES;
    [self createTF:_passwordTF andImage:@"login-icon-code-n" andPlaceholder:@"请输入密码"];
    _passwordTF.keyboardType = UIKeyboardTypeASCIICapable;
    
    _logInBtn = [[UIButton alloc]init];
    [self.bgImage addSubview:_logInBtn];
    [_logInBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordTF.mas_bottom).offset(20*ZCXWidthScale);
        make.centerX.mas_equalTo(self.bgImage);
        make.width.mas_equalTo(290*ZCXWidthScale);
        make.height.mas_equalTo(38*ZCXWidthScale);
    }];
    [_logInBtn setImage:[UIImage imageNamed:@"login-btn-login-n"] forState:UIControlStateNormal];
    [_logInBtn addTarget:self action:@selector(clickLogInBtn) forControlEvents:UIControlEventTouchUpInside];
    
    _registerBtn = [[UIButton alloc]init];
    [self.bgImage addSubview:_registerBtn];
    [_registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logInBtn.mas_bottom).offset(11*ZCXWidthScale);
        make.centerX.mas_equalTo(self.bgImage);
        make.width.mas_equalTo(290*ZCXWidthScale);
        make.height.mas_equalTo(38*ZCXWidthScale);
    }];
    [_registerBtn setImage:[UIImage imageNamed:@"login-btn-register-n"] forState:UIControlStateNormal];
    [_registerBtn addTarget:self action:@selector(clickRgisterBtn) forControlEvents:UIControlEventTouchUpInside];
}

-(void)createTF:(UITextField *)textField andImage:(NSString *)imageStr andPlaceholder:(NSString *)placeholderStr{
    textField.backgroundColor = RGBCOLOR(247, 247, 247);
    //显示文本字段的圆角样式边框
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.leftViewMode = UITextFieldViewModeAlways;
    UIView *numBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 49.5*ZCXWidthScale, 45*ZCXWidthScale)];
    UIImageView *numImageView = [[UIImageView alloc] initWithFrame:CGRectMake(24*ZCXWidthScale, 15*ZCXWidthScale, 12.5*ZCXWidthScale, 15.5*ZCXWidthScale)];
    numImageView.image = [UIImage imageNamed:imageStr];
    [numBgView addSubview:numImageView];
    textField.leftView = numBgView;
    //通过attributedPlaceholder属性修改占位文字颜色
    NSAttributedString *numAttrString = [[NSAttributedString alloc] initWithString:placeholderStr attributes:@{NSForegroundColorAttributeName:RGBCOLOR(128, 128, 128), NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    textField.attributedPlaceholder = numAttrString;
}

#pragma mark -- 点击事件
-(void)clickLogInBtn{
    if ([_userNameTF.text length] == 0 || [_passwordTF.text length]  == 0) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"提示" message:@"账号或密码不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [actionSheet addAction:action];
        [self presentViewController:actionSheet animated:YES completion:nil];
        return ;
    }
    [self.manager loginWithUserName:_userNameTF.text withPassword:_passwordTF.text];
    WS(weakSelf);
    self.manager.loginResultBlock = ^(NSString * str) {
        [ZCXTool showErrorMBProgressHUDtoView:weakSelf.view andText:str andDelay:1];
        if([str isEqualToString:@"登录成功"]){
            NSDictionary *dict = @{@"userName":weakSelf.userNameTF.text,@"password":weakSelf.passwordTF.text};
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:dict forKey:NSUserDefaultsUserNameAndPassword];
            [defaults synchronize];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            HomePageViewController *vc = [[HomePageViewController alloc]init];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
        }else{
        }
    };
}

-(void)clickRgisterBtn{
    ZCXRegisterViewController *vc = [[ZCXRegisterViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
