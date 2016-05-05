//
//  ChatFaceView.h
//
//  Created by zhiwen jiang on 16/3/24.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ShowFaceViewType)
{
    ShowEmojiFace = 0, /**< 表情图片 */
    ShowRecentFace,    /**< 最近发送过的图片，NSUserDefault存储 */
    ShowGifFace,       /**< 动画图片 */
};

@protocol ChatFaceViewDelegate <NSObject>

- (void)faceViewSendFace:(NSString *) strFaceName;
- (void)faceViewSendGifFace:(NSString *) strGifFacePath;

@end

@interface ChatFaceView : UIView

@property (weak, nonatomic) id<ChatFaceViewDelegate> delegate;
@property (assign, nonatomic) ShowFaceViewType faceViewType;

@end
