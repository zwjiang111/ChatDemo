//
//  ChatTextMessageCell.m
//
//  用于显示文本消息的文字
//
//  Created by zhiwen jiang on 16/4/12.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "ChatTextMessageCell.h"
#import "Masonry.h"
#import "FaceManager.h"

@interface ChatTextMessageCell ()

@property (nonatomic, strong) UILabel *messageTextL;
@property (nonatomic, copy, readonly) NSDictionary *textStyle;

@end

@implementation ChatTextMessageCell
@synthesize textStyle = _textStyle;

#pragma mark - 重写基类方法

- (void)updateConstraints
{
    [super updateConstraints];
    [self.messageTextL mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.edges.equalTo(self.messageContentView).with.insets(UIEdgeInsetsMake(8, 16, 8, 16));
    }];
}

#pragma mark - 公有方法

- (void)setup
{
    [self.messageContentView addSubview:self.messageTextL];
    [super setup];
}

- (void)configureCellWithData:(id)data
{
    [super configureCellWithData:data];

    NSMutableAttributedString *attrS = [FaceManager emotionStrWithString:data[kMessageConfigurationTextKey]];
    [attrS addAttributes:self.textStyle range:NSMakeRange(0, attrS.length)];
    self.messageTextL.attributedText = attrS;
}

#pragma mark - Getters方法

- (UILabel *)messageTextL
{
    if (!_messageTextL)
    {
        _messageTextL = [[UILabel alloc] init];
        _messageTextL.textColor = [UIColor blackColor];
        _messageTextL.font = [UIFont systemFontOfSize:16.0f];
        _messageTextL.numberOfLines = 0;
        _messageTextL.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _messageTextL;
}

- (NSDictionary *)textStyle
{
    if (!_textStyle)
    {
        UIFont *font = [UIFont systemFontOfSize:14.0f];
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
      //  style.alignment = self.messageOwner == MessageOwnerSelf ? NSTextAlignmentRight : NSTextAlignmentLeft;
        style.alignment = NSTextAlignmentLeft;
        style.paragraphSpacing = 0.25 * font.lineHeight;
        style.hyphenationFactor = 1.0;
        _textStyle = @{NSFontAttributeName: font,
                 NSParagraphStyleAttributeName: style};
    }
    return _textStyle;
}

@end
