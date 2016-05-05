//
//  UITableViewCell+CellIdentifier.h
//
//  Created by zhiwen jiang on 16/4/20.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChatMessageCell.h"

@interface ChatMessageCell (CellIdentifier)

/**
 *  用来获取cellIdentifier
 *
 *  @param messageConfiguration 消息类型,需要传入两个key
 *  kMessageConfigurationTypeKey     代表消息的类型
 *  kMessageConfigurationOwnerKey    代表消息的所有者
 */
+ (NSString *)cellIdentifierForMessageConfiguration:(NSDictionary *)messageConfiguration;


@end
