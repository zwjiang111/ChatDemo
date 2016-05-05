//
//  ChatViewController.h
//
//
//  Created by zhiwen jiang on 16/3/21.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Chat.h"

@interface ChatViewController : UIViewController

@property (copy, nonatomic) NSString *strChatterName  /**< 正在聊天的用户昵称 */;
@property (copy, nonatomic) NSString *strChatterThumb /**< 正在聊天的用户头像 */;

- (instancetype)initWithChatType:(MessageChat)messageChatType;

@end
