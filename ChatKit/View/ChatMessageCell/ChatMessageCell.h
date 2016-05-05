//
//  ChatMessageCell.h
//  ChatMessageCell 是所有ChatCell的父类
//  提供了delegate,messageOwner,messageType属性
//  Created by zhiwen jiang on 16/3/30.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SendImageView.h"
#import "ContentView.h"
#import "ChatUntiles.h"

@class ChatMessageCell;
@protocol ChatMessageCellDelegate <NSObject>

/**
 *  单点聊天记录的空白处，可以有来关闭键盘
 */
- (void)messageCellTappedBlank:(ChatMessageCell *)messageCell;

/**
 *  单点聊天记录的HEAD处，暂时未用上
 */
- (void)messageCellTappedHead:(ChatMessageCell *)messageCell;

/**
 *  单点聊天记录，可以用来浏览图片，播放视频、打开位置信息、播放语音聊天
 */
- (void)messageCellTappedMessage:(ChatMessageCell *)messageCell;

/**
 *  单点用户头像，用来查看用户详情
 */
- (void)messageCellTappedHeadImage:(ChatMessageCell *)messageCell;

/**
 *  响应快捷菜单
 */
- (void)messageCell:(ChatMessageCell *)messageCell withActionType:(ChatMessageCellMenuActionType)actionType;

/**
 *  消息发送失败时，重发消息
 */
- (void)messageCellResend:(ChatMessageCell *)messageCell;

/**
 *  正在上传或下载文件时，取消操作
 */
- (void)messageCellCancel:(ChatMessageCell *)messageCell;

@end


@interface ChatMessageCell : UITableViewCell

/**
 *  显示用户头像的UIImageView
 */
@property (nonatomic, strong) UIImageView *headImageView;

/**
 *  显示用户昵称的UILabel
 */
@property (nonatomic, strong) UILabel *nicknameLabel;

/**
 *  显示用户消息主体的View,所有的消息用到的textView,imageView都会被添加到这个view中 ->ContentView 自带一个CAShapeLayer的蒙版
 */
@property (nonatomic, strong) ContentView *messageContentView;

/**
 *  显示消息阅读状态的UIImageView -> 主要用于VoiceMessage
 */
@property (nonatomic, strong) UIImageView *messageReadStateImageView;

/**
 *  消息失败，重发按钮
 */
@property (nonatomic, strong) UIButton *messageResendButton;

/**
 *  取消正在送或上传的文件
 */
@property (nonatomic, strong) UIButton *messageCancelButton;

/**
 *  用来显示上传进度的UIProgressView
 */
@property (nonatomic, strong) UIProgressView *messageProgressView;

/**
 *  显示消息发送状态的UIImageView -> 用于消息发送不成功时显示
 */
@property (nonatomic, strong) SendImageView *messageSendStateImageView;

/**
 *  messageContentView的背景层
 */
@property (nonatomic, strong) UIImageView *messageContentBackgroundImageView;

/**
 *  如果是Gif图片，不显示背影图片，动图显示不需要带气泡的背景图片
 */
@property (nonatomic, assign) BOOL isGifImage;

@property (nonatomic, weak) id<ChatMessageCellDelegate> delegate;

/**
 *  消息的类型,只读类型,会根据自己的具体实例类型进行判断
 */
@property (nonatomic, assign, readonly) MessageType messageType;

/**
 *  消息的所有者,只读类型,会根据自己的reuseIdentifier进行判断
 */
@property (nonatomic, assign, readonly) MessageOwner messageOwner;

/**
 *  消息群组类型,只读类型,根据reuseIdentifier判断
 */
@property (nonatomic, assign) MessageChat messageChatType;


/**
 *  消息发送状态,当状态为MessageSendFail或MessageSendStateSending时,messageSendStateImageView显示
 */
@property (nonatomic, assign) MessageSendState messageSendState;

/**
 *  消息阅读状态,当状态为MessageUnRead时,messageReadStateImageView显示
 */
@property (nonatomic, assign) MessageReadState messageReadState;


#pragma mark - 公有方法

- (void)setup;
- (void)configureCellWithData:(id)data;

@end
