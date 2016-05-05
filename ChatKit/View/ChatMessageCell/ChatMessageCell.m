//
//  ChatMessageCell.m
//
//  Created by zhiwen jiang on 16/3/30.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "Chat.h"
#import "Masonry.h"
#import <objc/runtime.h>

@interface ChatMessageCell ()

@end

@implementation ChatMessageCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setup];
    }
    return self;
}

#pragma mark - 初始化方法

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

#pragma mark - 重写基类方法

- (void)updateConstraints
{
    [super updateConstraints];
    if ((self.messageOwner == MessageOwnerSystem) ||
        (self.messageOwner == MessageOwnerUnknown))
    {
        return;
    }
    
    if (self.messageOwner == MessageOwnerSelf)
    {
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.right.equalTo(self.contentView.mas_right).with.offset(-16);
            make.top.equalTo(self.contentView.mas_top).with.offset(16);
            make.width.equalTo(@50);
            make.height.equalTo(@50);
        }];
        
        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.top.equalTo(self.headImageView.mas_top);
            make.right.equalTo(self.headImageView.mas_left).with.offset(-16);
            make.width.mas_lessThanOrEqualTo(@120);
            make.height.equalTo(self.messageChatType == MessageChatGroup ? @32 : @16);
        }];
        
        [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.right.equalTo(self.headImageView.mas_left).with.offset(-6);
            make.top.equalTo(self.contentView.mas_top).with.offset(14);
            make.width.lessThanOrEqualTo(@([UIApplication sharedApplication].keyWindow.frame.size.width/5*3)).priorityHigh();
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16).priorityLow();
        }];
        
        [self.messageResendButton mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.right.equalTo(self.messageContentView.mas_left).with.offset(-6);
             make.centerY.equalTo(self.messageContentView.mas_centerY).with.offset(0);
             make.height.mas_equalTo(@(25));
             make.width.mas_equalTo(@(25));
         }];
        
        [self.messageSendStateImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.right.equalTo(self.messageContentView.mas_left).with.offset(-8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@50);
            make.height.equalTo(@50);
        }];
        
        [self.messageReadStateImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.right.equalTo(self.messageContentView.mas_left).with.offset(-8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    }
    else if (self.messageOwner == MessageOwnerOther)
    {
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.left.equalTo(self.contentView.mas_left).with.offset(16);
            make.top.equalTo(self.contentView.mas_top).with.offset(16);
            make.width.equalTo(@50);
            make.height.equalTo(@50);
        }];
        
        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.top.equalTo(self.headImageView.mas_top);
            make.left.equalTo(self.headImageView.mas_right).with.offset(16);
            make.width.mas_lessThanOrEqualTo(@120);
            make.height.equalTo(self.messageChatType == MessageChatGroup ? @16 : @0);
        }];
        
        [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.left.equalTo(self.headImageView.mas_right).with.offset(16);
            make.top.equalTo(self.nicknameLabel.mas_bottom).with.offset(4);
            make.width.lessThanOrEqualTo(@([UIApplication sharedApplication].keyWindow.frame.size.width/5*3)).priorityHigh();
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16).priorityLow();
        }];
        
        [self.messageSendStateImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.left.equalTo(self.messageContentView.mas_right).with.offset(8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        
        [self.messageReadStateImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.left.equalTo(self.messageContentView.mas_right).with.offset(8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    }
    
    [self.messageProgressView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.messageContentView.mas_left).with.offset(4);
         make.right.equalTo(self.messageContentView.mas_right).with.offset(-40);
         make.top.equalTo(self.messageContentView.mas_bottom).with.offset(10);
         make.height.mas_equalTo(@(5));
     }];
    
    [self.messageCancelButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.messageProgressView.mas_right).with.offset(4);
         make.top.equalTo(self.messageContentView.mas_bottom).with.offset(1);
         make.height.mas_equalTo(@(20));
         make.width.mas_equalTo(@(20));
     }];
    
    [self.messageContentBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
         make.edges.equalTo(self.messageContentView);
    }];
    
    if (self.messageChatType == MessageChatSingle)
    {
        [self.nicknameLabel mas_updateConstraints:^(MASConstraintMaker *make)
         {
            make.height.equalTo(@0);
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint touchPoint = [[touches anyObject] locationInView:self.contentView];
    if (CGRectContainsPoint(self.messageContentView.frame, touchPoint))
    {
        self.messageContentBackgroundImageView.highlighted = YES;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.messageContentBackgroundImageView.highlighted = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    self.messageContentBackgroundImageView.highlighted = NO;
}


#pragma mark - 私有方法

- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.messageContentView];
    [self.contentView addSubview:self.messageResendButton];
    [self.contentView addSubview:self.messageProgressView];
    [self.contentView addSubview:self.messageCancelButton];
    [self.contentView addSubview:self.messageReadStateImageView];
    [self.contentView addSubview:self.messageSendStateImageView];
    
    self.messageSendStateImageView.hidden = YES;
    self.messageReadStateImageView.hidden = YES;
    self.messageResendButton.hidden       = YES;
    
    if ((MessageTypeImage != [self messageType]) &&
        (MessageTypeVideo != [self messageType]))
    {
        self.messageCancelButton.hidden = YES;
        self.messageProgressView.hidden = YES;
    }
    
    if (self.messageOwner == MessageOwnerSelf)
    {
        [self.messageContentBackgroundImageView setImage:[[UIImage imageNamed:@"message_sender_background_normal"]
                                                          resizableImageWithCapInsets:UIEdgeInsetsMake(30, 16, 16, 24)
                                                          resizingMode:UIImageResizingModeStretch]];
        
        [self.messageContentBackgroundImageView setHighlightedImage:[[UIImage imageNamed:@"message_sender_background_highlight"]
                                                              resizableImageWithCapInsets:UIEdgeInsetsMake(30, 16, 16, 24)
                                                              resizingMode:UIImageResizingModeStretch]];
    }
    else if (self.messageOwner == MessageOwnerOther)
    {
        [self.messageContentBackgroundImageView setImage:[[UIImage imageNamed:@"message_receiver_background_normal"]
                                                   resizableImageWithCapInsets:UIEdgeInsetsMake(30, 16, 16, 24)
                                                   resizingMode:UIImageResizingModeStretch]];
        
        [self.messageContentBackgroundImageView setHighlightedImage:[[UIImage imageNamed:@"message_receiver_background_highlight"]
                                                              resizableImageWithCapInsets:UIEdgeInsetsMake(30, 16, 16, 24)
                                                              resizingMode:UIImageResizingModeStretch]];
    }
    
    self.messageContentView.layer.mask.contents = (__bridge id _Nullable)(self.messageContentBackgroundImageView.image.CGImage);
    [self.contentView insertSubview:self.messageContentBackgroundImageView belowSubview:self.messageContentView];
    
    [self updateConstraintsIfNeeded];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.contentView addGestureRecognizer:tap];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.minimumPressDuration = 1.f;
    [self.contentView addGestureRecognizer:longPress];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        CGPoint tapPoint = [tap locationInView:self.contentView];
        if (CGRectContainsPoint(self.messageContentView.frame, tapPoint))
        {
            [self.delegate messageCellTappedMessage:self];
        }
        else if (CGRectContainsPoint(self.headImageView.frame, tapPoint))
        {
            [self.delegate messageCellTappedHead:self];
        }
        else
        {
            [self.delegate messageCellTappedBlank:self];
        }
    }
}

- (void)handleTapHeadImage:(UITapGestureRecognizer *)tap
{
    [self.delegate messageCellTappedHeadImage:self];
}

- (void)resendButtonPressed:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellResend:)])
    {
        [self.delegate messageCellResend:self];
    }
}

- (void)cancelButtonPressed:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellCancel:)])
    {
        [self.delegate messageCellCancel:self];
    }
}

#pragma mark - 公有方法

- (void)configureCellWithData:(id)data
{
    self.nicknameLabel.text = data[kMessageConfigurationNicknameKey];
    [self.headImageView setImage:[UIImage imageNamed:@"test_send.png"]];
    
    if (data[kMessageConfigurationReadStateKey])
    {
        self.messageReadState = [data[kMessageConfigurationReadStateKey] integerValue];
    }
    
    if (data[kMessageConfigurationSendStateKey])
    {
        self.messageSendState = [data[kMessageConfigurationSendStateKey] integerValue];
    }
    
    if (MessageTypeGifImage == [data[kMessageConfigurationTypeKey] integerValue])
    {
        self.isGifImage = YES;//如果是Gif图片，不显示背影图片，动图显示不需要带气泡的背景图片
        self.messageContentBackgroundImageView.hidden = YES;
        self.messageCancelButton.hidden = YES;
        self.messageProgressView.hidden = YES;
    }
}

#pragma mark - Setters方法

- (void)setMessageSendState:(MessageSendState)messageSendState
{
    _messageSendState = messageSendState;
    if (self.messageOwner == MessageOwnerOther)
    {
        self.messageSendStateImageView.hidden = YES;
    }
    
    if (MessageSendFail == messageSendState)
    {
        self.messageResendButton.hidden = NO;
    }
    else if (MessageSendSuccess == messageSendState)
    {
        self.messageResendButton.hidden = YES;
    }
    
    self.messageSendStateImageView.messageSendState = messageSendState;
}

- (void)setMessageReadState:(MessageReadState)messageReadState
{
    _messageReadState = messageReadState;
    if (self.messageOwner == MessageOwnerSelf)
    {
        self.messageSendStateImageView.hidden = YES;
    }
    
    if (MessageUnRead == _messageReadState)
    {
        self.messageReadStateImageView.hidden = NO;
    }
    else
    {
        self.messageReadStateImageView.hidden = YES;
    }
}

#pragma mark - Getters方法
- (UIImageView *)headImageView
{
    if (!_headImageView)
    {
        _headImageView                        = [[UIImageView alloc] init];
        _headImageView.layer.cornerRadius     = 5.0f;
        _headImageView.layer.masksToBounds    = YES;
        _headImageView.backgroundColor        = [UIColor clearColor];
        _headImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapHeadImage:)];
        [_headImageView addGestureRecognizer:tap];
    }
    return _headImageView;
}

- (UILabel *)nicknameLabel
{
    if (!_nicknameLabel)
    {
        _nicknameLabel           = [[UILabel alloc] init];
        _nicknameLabel.font      = [UIFont systemFontOfSize:12.0f];
        _nicknameLabel.textColor = [UIColor blackColor];
        _nicknameLabel.text      = @"nickname";
    }
    return _nicknameLabel;
}

- (ContentView *)messageContentView
{
    if (!_messageContentView)
    {
        _messageContentView = [[ContentView alloc] init];
    }
    return _messageContentView;
}

- (UIButton *)messageResendButton
{
    if (!_messageResendButton)
    {
        _messageResendButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_messageResendButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_resend_normal"] forState:UIControlStateNormal];
        [_messageResendButton addTarget:self action:@selector(resendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_messageResendButton sizeToFit];
    }
    return _messageResendButton;
}

- (UIButton *)messageCancelButton
{
    if (!_messageCancelButton)
    {
        _messageCancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_messageCancelButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_cancel_normal"] forState:UIControlStateNormal];
        [_messageCancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_messageCancelButton sizeToFit];
    }
    return _messageCancelButton;
}

- (UIView *)messageProgressView
{
    if (!_messageProgressView)
    {
        _messageProgressView = [[UIProgressView alloc] init];
        _messageProgressView.progressViewStyle = UIProgressViewStyleDefault;
        _messageProgressView.progressTintColor = [UIColor greenColor];
    }
    return _messageProgressView;
}

- (UIImageView *)messageReadStateImageView
{
    if (!_messageReadStateImageView)
    {
        _messageReadStateImageView = [[UIImageView alloc] init];
        _messageReadStateImageView.backgroundColor = [UIColor redColor];
    }
    return _messageReadStateImageView;
}

- (SendImageView *)messageSendStateImageView
{
    if (!_messageSendStateImageView)
    {
        _messageSendStateImageView = [[SendImageView alloc] init];
    }
    return _messageSendStateImageView;
}

- (UIImageView *)messageContentBackgroundImageView
{
    if (!_messageContentBackgroundImageView)
    {
        _messageContentBackgroundImageView = [[UIImageView alloc] init];
    }
    return _messageContentBackgroundImageView;
}

- (MessageType)messageType
{
    if ([self isKindOfClass:[ChatTextMessageCell class]])
    {
        return MessageTypeText;
    }
    else if ([self isKindOfClass:[ChatImageMessageCell class]])
    {
        return MessageTypeImage;
    }
    else if ([self isKindOfClass:[ChatVideoMessageCell class]])
    {
        return MessageTypeVideo;
    }
    else if ([self isKindOfClass:[ChatVoiceMessageCell class]])
    {
        return MessageTypeVoice;
    }
    else if ([self isKindOfClass:[ChatLocationMessageCell class]])
    {
        return MessageTypeLocation;
    }
    else if ([self isKindOfClass:[ChatDateTimeMessageCell class]])
    {
        return MessageTypeDateTime;
    }
    else if ([self isKindOfClass:[ChatCallMessageCell class]])
    {
        if (((ChatCallMessageCell*)self).isVideoCall)
        {
            return MessageTypeVideoCall;
        }
        else
        {
            return MessageTypeVoiceCall;
        }
    }
 
    return MessageTypeUnknow;
}

- (MessageChat)messageChatType
{
    if ([self.reuseIdentifier containsString:@"GroupCell"])
    {
        return MessageChatGroup;
    }
    
    return MessageChatSingle;
}

- (MessageOwner)messageOwner
{
    if ([self.reuseIdentifier containsString:@"OwnerSelf"])
    {
        return MessageOwnerSelf;
    }
    else if ([self.reuseIdentifier containsString:@"OwnerOther"])
    {
        return MessageOwnerOther;
    }
    else if ([self.reuseIdentifier containsString:@"OwnerSystem"])
    {
        return MessageOwnerSystem;
    }
    return MessageOwnerUnknown;
}

@end



#pragma mark - ChatMessageCell扩展类方法(菜单)

NSString * const kChatMessageCellMenuControllerKey;

@interface ChatMessageCell (ChatMessageCellMenuAction)

@property (nonatomic, strong, readonly) UIMenuController *menuController;

@end

@implementation ChatMessageCell (ChatMessageCellMenuAction)

#pragma mark - 私有方法

//以下两个方法必须有
/*
 *  让UIView成为第一responser
 */
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/*
 *  根据action,判断UIMenuController是否显示对应aciton的title
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ((action == @selector(menuRelayAction)) ||
        (action == @selector(menuDeleteAction))||
        (action == @selector(menuCopyAction)))
    {
        return YES;
    }
        
    return NO;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGes
{
    if (longPressGes.state == UIGestureRecognizerStateBegan)
    {
        CGPoint longPressPoint = [longPressGes locationInView:self.contentView];
        if (!CGRectContainsPoint(self.messageContentView.frame, longPressPoint))
        {
            return;
        }
        [self becomeFirstResponder];
        //!!!此处使用self.superview.superview 获得到cell所在的tableView,不是很严谨
        CGRect targetRect = [self convertRect:self.messageContentView.frame toView:self.superview.superview];
        [self.menuController setTargetRect:targetRect inView:self.superview.superview];
        [self.menuController setMenuVisible:YES animated:YES];
    }
}


- (void)menuCopyAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:withActionType:)])
    {
        [self.delegate messageCell:self withActionType: ChatMessageCellMenuActionTypeCopy];
    }
}

- (void)menuDeleteAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:withActionType:)])
    {
        [self.delegate messageCell:self withActionType: ChatMessageCellMenuActionTypeDelete];
    }
}

- (void)menuRelayAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:withActionType:)])
    {
        [self.delegate messageCell:self withActionType: ChatMessageCellMenuActionTypeRelay];
    }
}

#pragma mark - Getters方法
- (UIMenuController *)menuController
{
    UIMenuController *menuController = objc_getAssociatedObject(self,&kChatMessageCellMenuControllerKey);
    if (!menuController)
    {
        menuController = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem   = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(menuCopyAction)];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(menuDeleteAction)];
        UIMenuItem *shareItem  = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(menuRelayAction)];
        
        if ((MessageTypeText == self.messageType)  ||
            (MessageTypeVideo == self.messageType) ||
            (MessageTypeImage == self.messageType))
        {
            [menuController setMenuItems:@[copyItem,deleteItem,shareItem]];
        }
        else
        {
            [menuController setMenuItems:@[deleteItem,shareItem]];
        }
        [menuController setArrowDirection:UIMenuControllerArrowDown];
        objc_setAssociatedObject(self, &kChatMessageCellMenuControllerKey, menuController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return menuController;
}
@end

