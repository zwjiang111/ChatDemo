//
//  MessageStateManager.h
//
//
//  Created by zhiwen jiang on 16/4/26.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ChatUntiles.h"

@interface MessageStateManager : NSObject

+ (instancetype)shareManager;


#pragma mark - 公有方法

- (MessageSendState)messageSendStateForIndex:(NSUInteger)index;
- (MessageReadState)messageReadStateForIndex:(NSUInteger)index;

- (void)setMessageSendState:(MessageSendState)messageSendState forIndex:(NSUInteger)index;
- (void)setMessageReadState:(MessageReadState)messageReadState forIndex:(NSUInteger)index;

- (void)cleanState;

@end

