//
//  ChatMoreView.h
//
//  moreItem类型， 更多view
//
//  Created by zhiwen jiang on 16/3/18.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ChatMoreItemType)
{
    ChatMoreItemImage = 0, /**< 显示拍照 */
    ChatMoreItemImageAlbum,/**< 显示相册 */
    ChatMoreItemVideo ,    /**< 显示拍视频 */
    ChatMoreItemVideoAlbum,/**< 显示视频相册 */
    ChatMoreItemLocation,  /**< 显示地理位置 */
    ChatMoreVoiceCall,     /**< 音频呼叫 */
    ChatMoreVideoCall,     /**< 视频呼叫 */
    ChatMoreFile,          /**< 文件转发 */
};

@protocol ChatMoreViewDataSource;
@protocol ChatMoreViewDelegate;

@interface ChatMoreView : UIView

@property (weak, nonatomic) id<ChatMoreViewDelegate>   delegate;
@property (weak, nonatomic) id<ChatMoreViewDataSource> dataSource;

@property (assign, nonatomic) NSUInteger   numberPerLine;
@property (assign, nonatomic) UIEdgeInsets edgeInsets;

- (void)reloadData;

@end


@protocol ChatMoreViewDelegate <NSObject>

@optional
/**
 *  moreView选中的index
 *
 *  @param moreView 对应的moreView
 *  @param index    选中的index
 */
- (void)moreView:(ChatMoreView *)moreView selectIndex:(ChatMoreItemType)itemType;

@end

@protocol ChatMoreViewDataSource <NSObject>

@required
/**
 *  获取数组中一共有多少个titles
 *
 *  @param moreView
 *
 *  @return titles
 */

- (NSArray *)titlesOfMoreView:(ChatMoreView *)moreView;

/**
 *  获取moreView展示的所有图片
 *
 *  @param moreView
 *
 *  @return imageNames
 */
- (NSArray *)imageNamesOfMoreView:(ChatMoreView *)moreView;

@end