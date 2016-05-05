//
//  ChatListCell.h
//  SpotGoods
//
//  Created by zhiwen jiang on 16/3/21.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  聊天列表页面Cell展示
 */
@interface ChatListCell : UITableViewCell

@property (weak, nonatomic) UIImageView *headImageView; /**< 显示用户头像 */
@property (weak, nonatomic) UILabel *titleLabel; /**< 显示用户名 */
@property (weak, nonatomic) UILabel *lastMessageLabel; /**< 显示最后条信息 */
@property (weak, nonatomic) UILabel *timeLabel; /**< 显示时间 */
@property (weak, nonatomic) UILabel *unreadLabel; /**< 显示未读消息数量 */

@property (assign, nonatomic) NSUInteger unReadCount;

@end
