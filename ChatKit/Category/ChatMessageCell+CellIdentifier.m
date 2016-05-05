//
//  UITableViewCell+CellIdentifier.m
//
//  Created by zhiwen jiang on 16/4/20.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "ChatMessageCell+CellIdentifier.h"

@implementation ChatMessageCell (CellIdentifier)

/**
 *  用来获取cellIdentifier
 *
 *  @param messageConfiguration 消息类型,需要传入两个key
 *  kMessageConfigurationTypeKey     代表消息的类型
 *  kMessageConfigurationOwnerKey    代表消息的所有者
 */
+ (NSString *)cellIdentifierForMessageConfiguration:(NSDictionary *)messageConfiguration
{
    MessageType messageType   = [messageConfiguration[kMessageConfigurationTypeKey] integerValue];
    MessageOwner messageOwner = [messageConfiguration[kMessageConfigurationOwnerKey] integerValue];
    MessageChat messageChat   = [messageConfiguration[kMessageConfigurationGroupKey] integerValue];
    NSString *strIdentifierKey   = @"ChatMessageCell";
    NSString *strOwnerKey;
    NSString *strTypeKey;
    NSString *strGroupKey;
    
    switch (messageOwner)
    {
        case MessageOwnerSystem:
            strOwnerKey = @"OwnerSystem";
            break;
        case MessageOwnerOther:
            strOwnerKey = @"OwnerOther";
            break;
        case MessageOwnerSelf:
            strOwnerKey = @"OwnerSelf";
            break;
        default:
            NSAssert(NO, @"Message Owner Unknow");
            break;
    }
    
    switch (messageType)
    {
        case MessageTypeVoice:
            strTypeKey = @"VoiceMessage";
            break;
        case MessageTypeImage:
        case MessageTypeGifImage:
            strTypeKey = @"ImageMessage";
            break;
        case MessageTypeVideo:
            strTypeKey = @"VideoMessage";
            break;
        case MessageTypeLocation:
            strTypeKey = @"LocationMessage";
            break;
        case MessageTypeDateTime:
            strTypeKey = @"DateTimeMessage";
            break;
        case MessageTypeText:
            strTypeKey = @"TextMessage";
            break;
        case MessageTypeVoiceCall:
        case MessageTypeVideoCall:
            strTypeKey = @"CallMessage";
            break;
        default:
            NSAssert(NO, @"Message Type Unknow");
            break;
    }
    
    switch (messageChat)
    {
        case MessageChatGroup:
            strGroupKey = @"GroupCell";
            break;
        case MessageChatSingle:
            strGroupKey = @"SingleCell";
            break;
        default:
            strGroupKey = @"";
            break;
    }
    
    return [NSString stringWithFormat:@"%@_%@_%@_%@",strIdentifierKey,strOwnerKey,strTypeKey,strGroupKey];
}


@end
