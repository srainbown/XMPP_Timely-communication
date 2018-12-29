//
//  ZCXMessageRightTableViewCell.m
//  XMPP
//
//  Created by mac on 28/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import "ZCXMessageRightTableViewCell.h"
#import "XMPPFramework.h"

@interface ZCXMessageRightTableViewCell()

@property (nonatomic, strong) UIImageView *userImage;
@property (nonatomic, strong) UITextView *contentTV;

@end

@implementation ZCXMessageRightTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = RGBCOLOR(239, 239, 239);
        [self createUI];
    }
    return self;
}
-(void)createUI{
    _userImage = [[UIImageView alloc]init];
    [self addSubview:_userImage];
    [_userImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15*ZCXWidthScale);
        make.top.mas_equalTo(10*ZCXWidthScale);
        make.width.height.mas_equalTo(44*ZCXWidthScale);
    }];
    _userImage.image = [UIImage imageNamed:@"default avatar"];
    
    _contentTV = [[UITextView alloc]init];
    [self addSubview:_contentTV];
    [_contentTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userImage);
        make.width.mas_equalTo(231*ZCXWidthScale);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(- 10 * ZCXWidthScale);
    }];
    _contentTV.backgroundColor = [UIColor whiteColor];
    _contentTV.textColor = RGBCOLOR(120, 120, 120);
    _contentTV.font = [UIFont systemFontOfSize:14];
    _contentTV.layer.masksToBounds = YES;
    _contentTV.layer.cornerRadius = 10;
    _contentTV.editable = NO;
    _contentTV.scrollEnabled = NO;
    _contentTV.textContainerInset = UIEdgeInsetsMake(10*ZCXWidthScale, 10*ZCXWidthScale, 10*ZCXWidthScale, 10*ZCXWidthScale);
    
}

- (void)setModel:(ZCXMessageModel *)model{
    //    XMPPJID *jid = model.from;
    //    _userLabel.text = jid.user;
    _contentTV.text = model.body;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
