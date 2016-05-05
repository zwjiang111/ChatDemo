//
//  ChatViewController.m
//
//
//  Created by zhiwen jiang on 16/3/21.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "ChatViewController.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "UITableView+CellRegister.h"
#import "ChatMessageCell+CellIdentifier.h"
#import "Masonry.h"
#import "RecordView.h"
#import "LocationViewController.h"
#import "MapLocationViewController.h"
#import "Chat.h"
#import "FaceManager.h"

#define kSelfName @"Fritt"
#define kSelfThumb @"test_send.png"////TODO temp code

@interface ChatViewController () <KeyboardViewDelegate,XMAVAudioPlayerDelegate,ChatMessageCellDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray  *messageArray;
@property (strong, nonatomic) UITableView     *tableView;
@property (strong, nonatomic) KeyboardView    *chatBar;
@property (strong, nonatomic) RecordView      *recordView; /**< 语音聊天录音指示view */
@property (strong, nonatomic) UIImageView     *backgroundImageView;

@property (assign, nonatomic) MessageChat messageChatType;
@end

@implementation ChatViewController


#pragma mark - 初始化方法

- (instancetype)initWithChatType:(MessageChat)messageChatType
{
    if ([super init])
    {
        _messageChatType = messageChatType;
    }
    return self;
}

#pragma mark - 重写基类方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [XMAVAudioPlayer sharePlayer].delegate = self;
    self.view.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234/255.0f blue:234/255.f alpha:1.0f];
    self.recordView.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.tableView addGestureRecognizer:tap];
    _messageArray = [NSMutableArray array];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.chatBar];
    [self.view addSubview:self.recordView];
    [self.view updateConstraintsIfNeeded];
    //临时代码
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"接收消息"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(receiveMessage)];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top).with.offset(60);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@(self.view.frame.size.height - 105));
    }];
    
    [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.tableView.mas_bottom).with.offset(4);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(@44);
    }];
    
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.width.mas_equalTo (@(140));
        make.height.mas_equalTo (@(140));
        make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
        make.centerY.equalTo(self.view.mas_centerY).with.offset(0);
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_chatBar setSuperViewHeight:[UIScreen mainScreen].bounds.size.height - (self.navigationController.navigationBar.isTranslucent ? 0 : 64)];
    [_chatBar setSuperViewWidth:[UIScreen mainScreen].bounds.size.width];
    [_chatBar rotate];
 }

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[XMAVAudioPlayer sharePlayer] stopAudioPlayer];
    [XMAVAudioPlayer sharePlayer].index = NSUIntegerMax;
    [XMAVAudioPlayer sharePlayer].URLString = nil;
    
}
#pragma mark - UITableViewDataSource & UITableViewDelegate方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = self.messageArray[indexPath.row];
    NSString *strIdentifier = [ChatMessageCell cellIdentifierForMessageConfiguration:
                               @{kMessageConfigurationGroupKey:message[kMessageConfigurationGroupKey],
                                 kMessageConfigurationOwnerKey:message[kMessageConfigurationOwnerKey],
                                 kMessageConfigurationTypeKey:message[kMessageConfigurationTypeKey]}];
    
    ChatMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    [messageCell configureCellWithData:message];
    messageCell.messageReadState = [[MessageStateManager shareManager] messageReadStateForIndex:indexPath.row];
    messageCell.messageSendState = [[MessageStateManager shareManager] messageSendStateForIndex:indexPath.row];
    messageCell.delegate = self;
    return messageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = self.messageArray[indexPath.row];
    NSString *identifier = [ChatMessageCell cellIdentifierForMessageConfiguration:
                            @{kMessageConfigurationGroupKey:message[kMessageConfigurationGroupKey],
                              kMessageConfigurationOwnerKey:message[kMessageConfigurationOwnerKey],
                              kMessageConfigurationTypeKey:message[kMessageConfigurationTypeKey]}];
    
    return [tableView fd_heightForCellWithIdentifier:identifier cacheByIndexPath:indexPath configuration:^(ChatMessageCell *cell)
            {
                [cell configureCellWithData:message];
            }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = self.messageArray[indexPath.row];
    if ([message[kMessageConfigurationTypeKey] integerValue] == MessageTypeVoice)
    {
        if (indexPath.row == [[XMAVAudioPlayer sharePlayer] index])
        {
            [(ChatVoiceMessageCell *)cell setVoiceMessageState:[[XMAVAudioPlayer sharePlayer] audioPlayerState]];
        }
    }
}

#pragma mark - KeyboardViewDelegate方法

- (void)chatBar:(KeyboardView *)chatBar sendMessage:(NSString *)message
{
    NSMutableDictionary *textMessageDict = [NSMutableDictionary dictionary];
    textMessageDict[kMessageConfigurationTypeKey]     = @(MessageTypeText);
    textMessageDict[kMessageConfigurationOwnerKey]    = @(MessageOwnerSelf);
    textMessageDict[kMessageConfigurationGroupKey]    = @(self.messageChatType);
    textMessageDict[kMessageConfigurationTextKey]     = message;
    textMessageDict[kMessageConfigurationNicknameKey] = kSelfName;
    textMessageDict[kMessageConfigurationAvatarKey]   = kSelfThumb;
    [self addMessage:textMessageDict];
}

- (void)chatBar:(KeyboardView *)chatBar sendCall:(NSString *)callTime withVideo:(BOOL)isVideo
{
    NSMutableDictionary *textMessageDict = [NSMutableDictionary dictionary];
    textMessageDict[kMessageConfigurationTypeKey]     = @(isVideo ? MessageTypeVideoCall:MessageTypeVoiceCall);
    textMessageDict[kMessageConfigurationOwnerKey]    = @(MessageOwnerSelf);
    textMessageDict[kMessageConfigurationGroupKey]    = @(self.messageChatType);
    textMessageDict[kMessageConfigurationTextKey]     = callTime;
    textMessageDict[kMessageConfigurationNicknameKey] = kSelfName;
    textMessageDict[kMessageConfigurationAvatarKey]   = kSelfThumb;
    [self addMessage:textMessageDict];
}

- (void)chatBar:(KeyboardView *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds
{
    NSMutableDictionary *voiceMessageDict = [NSMutableDictionary dictionary];
    voiceMessageDict[kMessageConfigurationTypeKey]         = @(MessageTypeVoice);
    voiceMessageDict[kMessageConfigurationOwnerKey]        = @(MessageOwnerSelf);
    voiceMessageDict[kMessageConfigurationGroupKey]        = @(self.messageChatType);
    voiceMessageDict[kMessageConfigurationNicknameKey]     = kSelfName;
    voiceMessageDict[kMessageConfigurationAvatarKey]       = kSelfThumb;
    voiceMessageDict[kMessageConfigurationVoiceKey]        = voiceFileName;
    voiceMessageDict[kMessageConfigurationVoiceSecondsKey] = @(seconds);
    [self addMessage:voiceMessageDict];
}

- (void)chatBar:(KeyboardView *)chatBar sendPictures:(NSArray *)pictures imageType:(BOOL)isGif
{
    NSMutableDictionary *imageMessageDict = [NSMutableDictionary dictionary];
    imageMessageDict[kMessageConfigurationTypeKey]     = @(isGif? MessageTypeGifImage : MessageTypeImage);
    imageMessageDict[kMessageConfigurationOwnerKey]    = @(MessageOwnerSelf);
    imageMessageDict[kMessageConfigurationGroupKey]    = @(self.messageChatType);
    imageMessageDict[kMessageConfigurationImageKey]    = [pictures firstObject];
    imageMessageDict[kMessageConfigurationNicknameKey] = kSelfName;
    imageMessageDict[kMessageConfigurationAvatarKey]   = kSelfThumb;
    [self addMessage:imageMessageDict];
}

- (void)chatBar:(KeyboardView *)chatBar sendVideos:(NSArray *)pictures
{
    NSMutableDictionary *imageMessageDict = [NSMutableDictionary dictionary];
    imageMessageDict[kMessageConfigurationTypeKey]     = @(MessageTypeVideo);
    imageMessageDict[kMessageConfigurationOwnerKey]    = @(MessageOwnerSelf);
    imageMessageDict[kMessageConfigurationGroupKey]    = @(self.messageChatType);
    imageMessageDict[kMessageConfigurationVideoKey]    = [pictures firstObject];
    imageMessageDict[kMessageConfigurationNicknameKey] = kSelfName;
    imageMessageDict[kMessageConfigurationAvatarKey]   = kSelfThumb;
    [self addMessage:imageMessageDict];
}

- (void)chatBar:(KeyboardView *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText
{
    NSMutableDictionary *locationMessageDict = [NSMutableDictionary dictionary];
    locationMessageDict[kMessageConfigurationTypeKey]     = @(MessageTypeLocation);
    locationMessageDict[kMessageConfigurationOwnerKey]    = @(MessageOwnerSelf);
    locationMessageDict[kMessageConfigurationGroupKey]    = @(self.messageChatType);
    locationMessageDict[kMessageConfigurationNicknameKey] = kSelfName;
    locationMessageDict[kMessageConfigurationAvatarKey]   = kSelfThumb;
    locationMessageDict[kMessageConfigurationTextKey]     = locationText;
    locationMessageDict[kMessageConfigurationLocationKey] = [NSString stringWithFormat:@"%.6f,%.6f", locationCoordinate.latitude, locationCoordinate.longitude];
    [self addMessage:locationMessageDict];
}

- (void)chatBarFrameDidChange:(KeyboardView *)chatBar frame:(CGRect)frame
{
    if (frame.origin.y == self.tableView.frame.size.height)
    {
        return;
    }
    
    [UIView animateWithDuration:.3f animations:^
    {
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make)
        {
            make.height.equalTo(@(frame.origin.y-56));
        }];
        
    } completion:nil];
}


- (void)startRecordVoice
{
    [_recordView startRecordVoice];
}

- (void)cancelRecordVoice
{
    [_recordView cancelRecordVoice];
}

- (void)endRecordVoice
{
   [_recordView endRecordVoice];
}

- (void)updateCancelRecordVoice
{
    [_recordView updateCancelRecordVoice];
}

- (void)updateContinueRecordVoice
{
    [_recordView updateContinueRecordVoice];
}

#pragma mark - ChatMessageCellDelegate方法
////TODO 临时代码，将删除
- (void)dismissAlertView:(id)object
{
    if ([object isKindOfClass:[UIAlertView class]])
    {
        UIAlertView *alert = (UIAlertView *)object;
        if ([alert isVisible])
        {
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        }
    }
}

- (void)messageCellTappedHead:(ChatMessageCell *)messageCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:messageCell];
    NSLog(@"tapHead :%@",indexPath);
}

- (void)messageCellTappedBlank:(ChatMessageCell *)messageCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:messageCell];
    NSLog(@"tapBlank :%@",indexPath);
    [self.chatBar endInputing];
}

- (void)messageCellTappedHeadImage:(ChatMessageCell *)messageCell
{
    ////TODO 临时代码，将删除
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"点击用户头像"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.0];
}

- (void)messageCellTappedMessage:(ChatMessageCell *)messageCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:messageCell];
    switch (messageCell.messageType)
    {
        case MessageTypeVoice:
        {
            NSString *voiceFileName = self.messageArray[indexPath.row][kMessageConfigurationVoiceKey];
            [[XMAVAudioPlayer sharePlayer] playAudioWithURLString:voiceFileName atIndex:indexPath.row];
            break;
        }
        case MessageTypeImage:
        case MessageTypeGifImage:
        {
            ////TODO 临时代码，将删除
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"点击图片"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.0];
            break;
        }

        case MessageTypeVideo:
        {
            break;
        }
            
        case MessageTypeLocation:
        {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:31.199196 longitude:121.461520];
            MapLocationViewController *mapView = [[MapLocationViewController alloc]init];
            mapView.location = location;
            [self.navigationController pushViewController:mapView animated:YES];
            [self.chatBar endInputing];//关闭键盘
            //self.navigationController.topViewController.hidesBottomBarWhenPushed = YES;
            break;
        }
        case MessageTypeVoiceCall:
        case MessageTypeVideoCall:
        {
            ////TODO 临时代码，将删除
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"点击音视频呼叫"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.0];

            break;
        }
        default:
            break;
    }
}

- (void)messageCell:(ChatMessageCell *)messageCell withActionType:(ChatMessageCellMenuActionType)actionType
{
    NSString *action = actionType == ChatMessageCellMenuActionTypeRelay ? @"转发" : @"复制";
    NSLog(@"messageCell :%@ willDoAction :%@",messageCell,action);
}

- (void)messageCellResend:(ChatMessageCell *)messageCell
{
    ////TODO 临时代码，将删除
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"重发消息!"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.0];
}

- (void)messageCellCancel:(ChatMessageCell *)messageCell
{
    ////TODO 临时代码，将删除
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"取消上传或下载!"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.0];
}

#pragma mark - XMAVAudioPlayerDelegate方法

- (void)audioPlayerStateDidChanged:(VoiceMessageState)audioPlayerState forIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    ChatVoiceMessageCell *voiceMessageCell = [self.tableView cellForRowAtIndexPath:indexPath];
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [voiceMessageCell setVoiceMessageState:audioPlayerState];
    });
}

#pragma mark - 私有方法
- (void)messageReadStateChanged:(MessageReadState)readState withProgress:(CGFloat)progress forIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    ChatMessageCell *messageCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![self.tableView.visibleCells containsObject:messageCell])
    {
        return;
    }
    messageCell.messageReadState = readState;
}

- (void)messageSendStateChanged:(MessageSendState)sendState withProgress:(CGFloat)progress forIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    ChatMessageCell *messageCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![self.tableView.visibleCells containsObject:messageCell])
    {
        return;
    }
    
    if ((MessageTypeImage == messageCell.messageType) ||
        (MessageTypeGifImage == messageCell.messageType))
    {
        [(ChatImageMessageCell *)messageCell setUploadProgress:progress];
    }
    else if (MessageTypeVideo == messageCell.messageType)
    {
        [(ChatVideoMessageCell *)messageCell setUploadProgress:progress];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        messageCell.messageSendState = sendState;
    });
}

- (void)reloadAfterReceiveMessage:(NSDictionary *)message
{
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:.3f animations:^
     {
         [self.tableView mas_updateConstraints:^(MASConstraintMaker *make)
          {
              make.height.equalTo(@([[UIScreen mainScreen] bounds].size.height-105));
              [self.chatBar endInputing];
          }];
         
     } completion:nil];
}

- (void)addMessage:(NSDictionary *)message
{
    [self.messageArray addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [self sendMessage:message];
}

- (void)sendMessage:(NSDictionary *)message
{
    //临时代码，模拟发送消息
    [[MessageStateManager shareManager] setMessageSendState:MessageSendStateSending forIndex:[self.messageArray indexOfObject:message]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
       CGFloat progress = 0.0f;
       for (int i=0; i<5; i++)
       {
           dispatch_async (dispatch_get_main_queue(), ^
           {
               [self messageSendStateChanged:MessageSendStateSending withProgress:progress forIndex:[self.messageArray indexOfObject:message]];
           });
           progress += 0.2f;
           sleep(1);
       }
       
       dispatch_async (dispatch_get_main_queue(), ^
       {
           [[MessageStateManager shareManager] setMessageSendState:MessageSendSuccess forIndex:[self.messageArray indexOfObject:message]];
           [self messageSendStateChanged:MessageSendSuccess withProgress:1.0f forIndex:[self.messageArray indexOfObject:message]];
       });
    });
}

//临时代码，模拟接收消息
- (void)receiveMessage
{
    int messageType = random() % 8;
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    if (0 == messageType)
    {
        messageDict[kMessageConfigurationTextKey] = @"hello world[流汗][偷笑]我来自于上海";
        messageDict[kMessageConfigurationTypeKey] = @(MessageTypeText);
        messageDict[kMessageConfigurationOwnerKey] = @(MessageOwnerOther);
    }
    else if (1 == messageType)
    {
        messageDict[kMessageConfigurationImageKey] = [UIImage imageNamed:@"test_send"];
        messageDict[kMessageConfigurationTypeKey] = @(MessageTypeImage);
        messageDict[kMessageConfigurationOwnerKey] = @(MessageOwnerOther);
    }
    else if (2 == messageType)
    {
        messageDict[kMessageConfigurationTypeKey] = @(MessageTypeDateTime);
        messageDict[kMessageConfigurationTextKey] = @"2016-05-3 13:21:09";
        messageDict[kMessageConfigurationOwnerKey] = @(MessageOwnerSystem);
    }
    else if (3 == messageType)
    {
        messageDict[kMessageConfigurationTypeKey]         = @(MessageTypeVoice);
        messageDict[kMessageConfigurationOwnerKey]        = @(MessageOwnerOther);
        messageDict[kMessageConfigurationVoiceSecondsKey] = @(random()%60);
    }
    else if (4 == messageType)
    {
        messageDict[kMessageConfigurationTypeKey]   = @(MessageTypeVoiceCall);
        messageDict[kMessageConfigurationOwnerKey]  = @(MessageOwnerOther);
        messageDict[kMessageConfigurationTextKey]   = @"音频呼叫 11‘";
    }
    else if (5 == messageType)
    {
        messageDict[kMessageConfigurationTypeKey]   = @(MessageTypeVideoCall);
        messageDict[kMessageConfigurationOwnerKey]  = @(MessageOwnerOther);
        messageDict[kMessageConfigurationTextKey]   = @"视频呼叫 33‘";
    }
    else if (6 == messageType)
    {
        messageDict[kMessageConfigurationTypeKey]     = @(MessageTypeLocation);
        messageDict[kMessageConfigurationOwnerKey]    = @(MessageOwnerOther);
        messageDict[kMessageConfigurationTextKey]     = @"上海市平江路8号";
        messageDict[kMessageConfigurationLocationKey] = [NSString stringWithFormat:@"31.199196,121.461520"];
    }
    else if (7 == messageType)
    {
        NSString *strFaceImageName = [FaceManager faceImageNameWithFaceID:200+random()%15];
        NSString *strBundlePath =  [[NSBundle mainBundle]pathForResource:@"gifface" ofType:@"bundle"];
        NSString *strLocalPath = [[NSBundle bundleWithPath:strBundlePath] pathForResource:strFaceImageName ofType:@"gif"];
        
        messageDict[kMessageConfigurationTypeKey]     = @(MessageTypeGifImage);
        messageDict[kMessageConfigurationOwnerKey]    = @(MessageOwnerOther);
        messageDict[kMessageConfigurationImageKey]    = strLocalPath;
    }

    messageDict[kMessageConfigurationGroupKey] = @(MessageChatSingle);
    [self addMessage:messageDict];
    [self reloadAfterReceiveMessage:messageDict];
}

#pragma mark - Getters方法

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kMinHeight) style:UITableViewStylePlain];
        
        [_tableView registerChatMessageCellClass];
        _tableView.delegate           = self;
        _tableView.dataSource         = self;
        _tableView.backgroundColor    = self.view.backgroundColor;
        _tableView.estimatedRowHeight = 66;
        _tableView.contentInset       = UIEdgeInsetsMake(8, 0, 0, 0);
        _tableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
        
        //加此imageview解决UITabelViewCell第一条记录显示起始高度问题
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        _backgroundImageView.backgroundColor  = self.view.backgroundColor;
        [self.view addSubview:_backgroundImageView ] ;
    }
    return _tableView;
}

- (KeyboardView *)chatBar
{
    if (!_chatBar)
    {
        _chatBar = [[KeyboardView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kMinHeight - (self.navigationController.navigationBar.isTranslucent ? 0 : 64), self.view.frame.size.width, kMinHeight)];
        [_chatBar setSuperViewHeight:[UIScreen mainScreen].bounds.size.height - (self.navigationController.navigationBar.isTranslucent ? 0 : 64)];
        [_chatBar setSuperViewWidth:[UIScreen mainScreen].bounds.size.width];
        _chatBar.delegate = self;
    }
    return _chatBar;
}

- (RecordView *)recordView
{
    if (!_recordView)
    {
        _recordView = [[RecordView alloc] init];
        _recordView.layer.cornerRadius = 10;
        _recordView.backgroundColor    = [UIColor blueColor];
        _recordView.clipsToBounds      = YES;
        _recordView.backgroundColor    = [UIColor colorWithWhite:0.3 alpha:1];
    }
    return _recordView;
}
@end
