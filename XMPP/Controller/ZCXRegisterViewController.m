//
//  ZCXRegisterViewController.m
//  XMPP
//
//  Created by mac on 26/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import "ZCXRegisterViewController.h"
#import "ZCXXMPPManager.h"

@interface ZCXRegisterViewController ()

@property (nonatomic, strong) ZCXXMPPManager *manager;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UITextField *userTF;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UITextField *passwordAgainTF;
@property (nonatomic, strong) UIButton *registerBtn;

@end

@implementation ZCXRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"注册";
    
    self.manager = [ZCXXMPPManager sharedInstance];
    [self createUI];
}

#pragma mark -- UI
-(void)createUI{
    
    _bgImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_bgImageView];
    _bgImageView.image = [UIImage imageNamed:@"register_bg1"];
    _bgImageView.userInteractionEnabled = YES;
    
    //输入用户名
    _userTF = [[UITextField alloc]init];
    [_bgImageView addSubview:_userTF];
    [_userTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(150*ZCXWidthScale);
        make.centerX.mas_equalTo(self.bgImageView);
        make.width.mas_equalTo(340*ZCXWidthScale);
        make.height.mas_equalTo(50*ZCXWidthScale);
    }];
    _userTF.keyboardType = UIKeyboardTypeASCIICapable;
    [self createTF:_userTF andImage:@"register-icon-user-n" andPlaceholder:@"请输入用户名"];
    
    //输入密码
    _passwordTF = [[UITextField alloc]init];
    [_bgImageView addSubview:_passwordTF];
    [_passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userTF.mas_bottom).offset(20*ZCXWidthScale);
        make.centerX.mas_equalTo(self.bgImageView);
        make.width.mas_equalTo(340*ZCXWidthScale);
        make.height.mas_equalTo(50*ZCXWidthScale);
    }];
    [self createTF:_passwordTF andImage:@"login-icon-code-n" andPlaceholder:@"请输入密码"];
    _passwordTF.secureTextEntry = YES;
    _passwordTF.keyboardType = UIKeyboardTypeASCIICapable;
    //确认密码
    _passwordAgainTF = [[UITextField alloc]init];
    [_bgImageView addSubview:_passwordAgainTF];
    [_passwordAgainTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordTF.mas_bottom).offset(20*ZCXWidthScale);
        make.centerX.mas_equalTo(self.bgImageView);
        make.width.mas_equalTo(340*ZCXWidthScale);
        make.height.mas_equalTo(50*ZCXWidthScale);
    }];
    [self createTF:_passwordAgainTF andImage:@"login-icon-code-n" andPlaceholder:@"再次确认密码"];
    _passwordAgainTF.secureTextEntry = YES;
    _passwordAgainTF.keyboardType = UIKeyboardTypeASCIICapable;

    //注册按钮
    _registerBtn = [[UIButton alloc]init];
    [self.view addSubview:_registerBtn];
    [_registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.passwordAgainTF.mas_bottom).offset(20*ZCXWidthScale);
        make.width.mas_equalTo(340*ZCXWidthScale);
        make.height.mas_equalTo(38*ZCXWidthScale);
    }];
    [_registerBtn setImage:[UIImage imageNamed:@"register-btn-register-n"] forState:UIControlStateNormal];
    [_registerBtn addTarget:self action:@selector(clickRegisterBtn) forControlEvents:UIControlEventTouchUpInside];
    
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
-(void)clickRegisterBtn{
    BOOL userNmae = [self checkUserName];
    if (!userNmae) {
        return;
    }
    BOOL password = [self checkPassword];
    if (!password) {
        return;
    }
    [self.manager registerWithUserName:self.userTF.text withPassword:self.passwordTF.text];
    WS(weakSelf);
    self.manager.registerResultBlock = ^(NSString * str) {
        [ZCXTool showErrorMBProgressHUDtoView:weakSelf.view andText:str andDelay:1];
        if ([str isEqualToString:@"注册成功"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            
        }
    };
}

#pragma mark -- 密码验证
-(BOOL)checkUserName{
    if ([_userTF.text length]  == 0) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"提示" message:@"用户名不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [actionSheet addAction:action];
        [self presentViewController:actionSheet animated:YES completion:nil];
        return NO;
    }
    return YES;
}

-(BOOL)checkPassword{
    if ([_passwordTF.text length]  == 0 || [_passwordAgainTF.text length] == 0) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"提示" message:@"密码不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [actionSheet addAction:action];
        [self presentViewController:actionSheet animated:YES completion:nil];
        return NO;
    }
    BOOL isMatch = [_passwordTF.text isEqualToString:_passwordAgainTF.text];
    if (!isMatch) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"提示" message:@"两次密码不一致" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [actionSheet addAction:action];
        [self presentViewController:actionSheet animated:YES completion:nil];
        return NO;
    }
    return YES;
}


@end
