//
//  HomePageViewController.m
//  XMPP
//
//  Created by mac on 20/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import "HomePageViewController.h"
#import "ZCXXMPPManager.h"
#import "ZCXMessageModel.h"
#import "ZCXMessageLeftTableViewCell.h"
#import "ZCXMessageRightTableViewCell.h"

@interface HomePageViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) ZCXXMPPManager *manager;

@property (nonatomic, strong) UITextField *contentTF;
@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"定向通讯";
    self.manager = [ZCXXMPPManager sharedInstance];
    [self createUI];

    XMPPJID *friendJid = [XMPPJID jidWithUser:@"iOS-test" domain:KDomin resource:KResource];
    self.friendJID = friendJid;
    [self reloadMessage];
    WS(weakSelf);
    self.manager.didSendMessageBlock = ^(XMPPMessage * message) {
        [weakSelf didSendMessageBlock:message];
    };
    self.manager.didReceiveMessageBlock = ^(XMPPMessage * message) {
        [weakSelf didReceiveMessageBlock:message];
    };
}

#pragma mark -- 懒加载
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark -- 检索信息
-(void)reloadMessage{
    //通过coredata把信息取出来
    NSManagedObjectContext *context = [self.manager context];
    //创建请求
    //底层XMPPMessageArchiving_Message_CoreDataObject表中存放所有的聊天记录
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //通过 谓词 去筛选
    //bareJIDStr代表的是好友的账号
    //streamBareJidStr代表的是我的账号
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ and streamBareJidStr == %@",self.friendJID.bare,[self.manager xmppStream].myJID.bare];
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    //设置排序
    [request setSortDescriptors:@[sort]];
    //设置谓词
    [request setPredicate:predicate];
    //用coredata得到了聊天记录
    NSArray *fetchArr = [context executeFetchRequest:request error:nil];
    //将聊天记录封装成MessageModel
    for (XMPPMessageArchiving_Message_CoreDataObject *message in fetchArr) {
        ZCXMessageModel *showMessage = [[ZCXMessageModel alloc] init];
        //  如果消息是发送出去的，就把showMessage的from赋值为streamBarJID
        if (message.isOutgoing) {
            showMessage.from = [XMPPJID jidWithString:message.streamBareJidStr];
        }else{
            //  封装
            XMPPJID *jid = [XMPPJID jidWithString:message.bareJidStr];
            showMessage.from = jid;
        }
        //  接收本地消息的内容
        showMessage.body = message.body;
        //  添加到数据源中
        [self.dataArray addObject:showMessage];
    }
}

-(void)createUI{
    
    _contentTF = [[UITextField alloc]init];
    [self.view addSubview:_contentTF];
    [_contentTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15*ZCXWidthScale);
        make.bottom.mas_equalTo(-7*ZCXWidthScale);
        make.width.mas_equalTo(294*ZCXWidthScale);
        make.height.mas_equalTo(30*ZCXWidthScale);
    }];
    _contentTF.layer.masksToBounds = YES;
    _contentTF.layer.cornerRadius = 5;
    _contentTF.backgroundColor = RGBCOLOR(239, 239, 239);
    _contentTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _contentTF.leftViewMode = UITextFieldViewModeAlways;
    
    _sendBtn = [[UIButton alloc]init];
    [self.view addSubview:_sendBtn];
    [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentTF);
        make.right.mas_equalTo(-15*ZCXWidthScale);
        make.height.mas_equalTo(30*ZCXWidthScale);
    }];
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_sendBtn setTitleColor:RGBCOLOR(120, 120, 120) forState:UIControlStateNormal];
    _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.messageTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT -44*ZCXWidthScale) style:UITableViewStylePlain];
    [self.view addSubview:self.messageTableView];
    self.messageTableView.delegate = self;
    self.messageTableView.dataSource = self;
    self.messageTableView.backgroundColor = RGBCOLOR(239, 239, 239);
    self.messageTableView.showsVerticalScrollIndicator = NO;
    self.messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZCXMessageModel *model = self.dataArray[indexPath.row];
    CGFloat height = [self getLabelHeightWithContent:model.body andLabelWidth:211*ZCXWidthScale andLabelFontSize:14];
    return height + 20*ZCXWidthScale + 20*ZCXWidthScale;
}

-(CGFloat)getLabelHeightWithContent:(NSString *)content andLabelWidth:(CGFloat)width andLabelFontSize:(int)font{
    
    CGSize size = [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:font]} context:nil].size;
    return size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZCXMessageModel *model = self.dataArray[indexPath.row];
    XMPPJID *sendJid = model.from;
    if ([[sendJid bareJID] isEqualToJID:[self.friendJID bareJID]]) {
        static NSString *leftCellId = @"leftCellId";
        ZCXMessageLeftTableViewCell *leftCell = [tableView dequeueReusableCellWithIdentifier:leftCellId];
        if (leftCell == nil) {
            leftCell = [[ZCXMessageLeftTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftCellId];
        }
        leftCell.model = model;
        leftCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return leftCell;
    }else{
        static NSString *rightCellId = @"rightCellId";
        ZCXMessageRightTableViewCell *rightCell = [tableView dequeueReusableCellWithIdentifier:rightCellId];
        if (rightCell == nil) {
            rightCell = [[ZCXMessageRightTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rightCellId];
        }
        rightCell.model = model;
        rightCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return rightCell;
    }
}


#pragma mark -- 点击事件
//发送消息事件
-(void)sendBtnClick{
    
//    XMPPJID *friendJid = [XMPPJID jidWithUser:@"custom" domain:KDomin resource:KResource];
    //创建消息，chat代表聊天消息，friendJid代表要发送的对象
    
//    normal：类似于email，主要特点是不要求响应；
//    chat：类似于qq里的好友即时聊天，主要特点是实时通讯；
//    groupchat：类似于聊天室里的群聊；
//    headline：用于发送alert和notification；
//    error：如果发送message出错，发现错误的实体会用这个类别来通知发送者出错了；
    if ([self.contentTF.text isEqualToString:@""]) {
        [ZCXTool showErrorMBProgressHUDtoView:self.view andText:@"请输入您要发送的内容" andDelay:1];
        return;
    }
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
    [message addBody:self.contentTF.text];
    //发送消息
    [self.manager.xmppStream sendElement:message];

}

-(void)didSendMessageBlock:(XMPPMessage *)message{
    self.contentTF.text = @"";
    [self showMessage:message];
}

-(void)didReceiveMessageBlock:(XMPPMessage *)message{
    XMPPJID *jid = message.from;
    if ([[self.friendJID bareJID] isEqualToJID:[jid bareJID]]) {
        [self showMessage:message];
    }
}

//  封装向数据源中插入数据，进行显示的方法
- (void)showMessage:(XMPPMessage *)message {
    if (message.body == nil || [message.body isEqual:@"null"]) {
        return;
    }
    //  将XMPPMessage转化为我们自己建立的MessageModel，目的就是防止，本地消息类型和收到的远程消息类型不一样
    ZCXMessageModel *model = [[ZCXMessageModel alloc] init];
    model.body = message.body;
    model.from = message.from;
    //  1.插入数据源
    [self.dataArray addObject:model];
    //  2.插入单元格
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    //  自动滚动
    [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


@end
