//
//  ChatImageMessageCell.m
//
//  用来显示image的UIImageView
//
//  Created by zhiwen jiang on 16/4/7.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "ChatImageMessageCell.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "Masonry.h"

@interface ChatImageMessageCell ()

@property (nonatomic, strong) FLAnimatedImageView *messageImageView;


@end

@implementation ChatImageMessageCell

#pragma mark - 重写基类方法

- (void)updateConstraints
{
    [super updateConstraints];
    [self.messageImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.edges.equalTo(self.messageContentView);
        make.height.lessThanOrEqualTo(@150);
    }];
    
    [self.messageContentView mas_updateConstraints:^(MASConstraintMaker *make)
     {
        make.width.equalTo(@(150));
     }];
}

#pragma mark - 公有方法

- (void)setup
{
    [self.messageContentView addSubview:self.messageImageView];
    [super setup];
}

- (void)configureCellWithData:(id)data
{
    [super configureCellWithData:data];
    id image = data[kMessageConfigurationImageKey];
    
    if ([image isKindOfClass:[UIImage class]])
    {
        self.messageImageView.image = image;
    }
    else if ([image isKindOfClass:[NSString class]])
    {
        if (self.isGifImage)
        {
            self.messageImageView.userInteractionEnabled = YES;
            FLAnimatedImage *animationImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:data[kMessageConfigurationImageKey]]];
            self.messageImageView.animatedImage = animationImage;
        }
    }
    else
    {
        NSLog(@"未知的图片类型");
    }
}


#pragma mark - Setters方法

- (void)setUploadProgress:(CGFloat)uploadProgress
{
    [self setMessageSendState:MessageSendStateSending];
    [self.messageProgressView setProgress:uploadProgress];
}

- (void)setMessageSendState:(MessageSendState)messageSendState
{
    [super setMessageSendState:messageSendState];
    if (messageSendState == MessageSendStateSending)
    {
        if (!self.messageProgressView.superview)
        {
            [self.contentView addSubview:self.messageProgressView];
            [self.contentView addSubview:self.messageCancelButton];
        }
    }
    else
    {
        [self.messageProgressView removeFromSuperview];
        [self.messageCancelButton removeFromSuperview];
    }
}

#pragma mark - Getters方法

- (UIImageView *)messageImageView
{
    if (!_messageImageView)
    {
        _messageImageView = [[FLAnimatedImageView alloc] init];
        _messageImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _messageImageView;
    
}

@end
