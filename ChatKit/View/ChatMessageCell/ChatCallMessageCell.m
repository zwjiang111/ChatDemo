//
//  ChatCallMessageCell.m
//
//  用于显示音视频呼叫信息
//
//  Created by zhiwen jiang on 16/4/6.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "ChatCallMessageCell.h"
#import "Masonry.h"
#import "FaceManager.h"

@interface ChatCallMessageCell ()


@property (nonatomic, strong) UILabel *messageCallLabel;
@property (nonatomic, strong) UIImageView *messageCallImage;

@end

@implementation ChatCallMessageCell

#pragma mark - 重写基类方法

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.messageOwner == MessageOwnerSelf)
    {
        [self.messageCallLabel mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.left.equalTo(self.messageContentView.mas_left).with.offset(8);
            make.right.equalTo(self.messageContentView.mas_right).with.offset(-40);
            make.top.equalTo(self.messageContentView.mas_top).with.offset(4);
            make.bottom.equalTo(self.messageContentView.mas_bottom).with.offset(-4);
        }];
        
        [self.messageCallImage mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.right.equalTo(self.messageContentView.mas_right).with.offset(-10);
            make.top.equalTo(self.messageContentView.mas_top).with.offset(8);
            make.width.mas_equalTo(@(32));
            make.height.mas_equalTo(@(32));
        }];
    }
    else if (self.messageOwner == MessageOwnerOther)
    {
        [self.messageCallLabel mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.left.equalTo(self.messageContentView.mas_left).with.offset(40);
            make.right.equalTo(self.messageContentView.mas_right).with.offset(-8);
            make.top.equalTo(self.messageContentView.mas_top).with.offset(4);
            make.bottom.equalTo(self.messageContentView.mas_bottom).with.offset(-4);
        }];
        
        [self.messageCallImage mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.messageContentView.mas_left).with.offset(10);
             make.top.equalTo(self.messageContentView.mas_top).with.offset(8);
             make.width.mas_equalTo(@(32));
             make.height.mas_equalTo(@(32));
        }];
    }
    
    [self.messageContentView mas_updateConstraints:^(MASConstraintMaker *make)
     {
        make.width.equalTo(@(140));
    }];
}

#pragma mark - 公有方法

- (void)setup
{
    [self.messageContentView addSubview:self.messageCallLabel];
    [self.messageContentView addSubview:self.messageCallImage];
    [super setup];
}

- (void)configureCellWithData:(id)data
{
    [super configureCellWithData:data];
    if (MessageTypeVideoCall == [data[kMessageConfigurationTypeKey] integerValue])
    {
        _isVideoCall = YES;
        _messageCallImage.image = [UIImage imageNamed:@"chat_bar_video_call"];
    }
    else
    {
        _isVideoCall = NO;
        _messageCallImage.image = [UIImage imageNamed:@"chat_bar_voice_call"];
    }
    
    self.messageCallLabel.text = [NSString stringWithFormat:@"%@", data[kMessageConfigurationTextKey]];
}

#pragma mark - Getters方法

- (UILabel *)messageCallLabel
{
    if (!_messageCallLabel)
    {
        _messageCallLabel = [[UILabel alloc] init];
        _messageCallLabel.font = [UIFont systemFontOfSize:14.0f];
        _messageCallLabel.text = @"0''";
    }
    return _messageCallLabel;
}

- (UIImageView *)messageCallImage
{
    if (!_messageCallImage)
    {
        _messageCallImage = [[UIImageView alloc] init];
    }
    return _messageCallImage;
}
@end
