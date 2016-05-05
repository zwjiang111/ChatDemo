//
//  MessageStateManager.m
//
//
//  Created by zhiwen jiang on 16/4/26.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "MessageStateManager.h"

@interface MessageStateManager ()

@property (nonatomic, strong) NSMutableDictionary *messageReadStateDict;
@property (nonatomic, strong) NSMutableDictionary *messageSendStateDict;

@end

@implementation MessageStateManager

+ (instancetype)shareManager
{
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if ([super init])
    {
        _messageReadStateDict = [NSMutableDictionary dictionary];
        _messageSendStateDict = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - 公有方法

- (MessageSendState)messageSendStateForIndex:(NSUInteger)index
{
    if (_messageSendStateDict[@(index)])
    {
        return [_messageSendStateDict[@(index)] integerValue];
    }
    return MessageSendSuccess;
}

- (MessageReadState)messageReadStateForIndex:(NSUInteger)index
{
    if (_messageReadStateDict[@(index)])
    {
        return [_messageReadStateDict[@(index)] integerValue];
    }
    return MessageReaded;
}

- (void)setMessageSendState:(MessageSendState)messageSendState forIndex:(NSUInteger)index
{
    _messageSendStateDict[@(index)] = @(messageSendState);
}

- (void)setMessageReadState:(MessageReadState)messageReadState forIndex:(NSUInteger)index
{
    _messageReadStateDict[@(index)] = @(messageReadState);
}

- (void)cleanState
{
    [_messageSendStateDict removeAllObjects];
    [_messageReadStateDict removeAllObjects];
}

@end
