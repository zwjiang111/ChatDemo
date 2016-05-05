//
//  KeyboardView.h
//
//  仿微信信息输入框,支持语音,文字,表情,选择照片,拍照
//
//  Created by zhiwen jiang on 16/3/22.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#define kMaxHeight          60.0f
#define kMinHeight          45.0f
#define kFunctionViewHeight 210.0f

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, FunctionViewShowType)
{
    FunctionViewShowNothing,   /**< 不显示functionView */
    FunctionViewShowFace,      /**< 显示表情View */
    FunctionViewShowVoice,     /**< 显示录音view */
    FunctionViewShowMore,      /**< 显示更多view */
    FunctionViewShowKeyboard,  /**< 显示键盘 */
};

@protocol KeyboardViewDelegate;

@interface KeyboardView : UIView

@property (assign, nonatomic) CGFloat superViewHeight;

@property (assign, nonatomic) CGFloat superViewWidth;

@property (weak, nonatomic) id<KeyboardViewDelegate> delegate;

/**
 *  结束输入状态
 */
- (void)endInputing;

/**
 *  旋转
 */
- (void)rotate;


@end

/**
 *  XMKeyboardView代理事件,发送图片,地理位置,文字,语音信息等
 */
@protocol KeyboardViewDelegate <NSObject>


@optional

/**
 *  开始录音
 */
- (void)startRecordVoice;

/**
 *  取消录音
 */
- (void)cancelRecordVoice;

/**
 *  录音结束
 */
- (void)endRecordVoice;

/**
 *  更新录音显示状态,手指向上滑动后提示松开取消录音
 */
- (void)updateCancelRecordVoice;

/**
 *  更新录音状态,手指重新滑动到范围内,提示向上取消录音
 */
- (void)updateContinueRecordVoice;

/**
 *  chatBarFrame改变回调
 *
 *  @param chatBar 
 */
- (void)chatBarFrameDidChange:(KeyboardView *)chatBar frame:(CGRect)frame;


/**
 *  发送图片信息,支持多张图片
 *
 *  @param chatBar
 *  @param pictures 需要发送的图片信息
 */
- (void)chatBar:(KeyboardView *)chatBar sendPictures:(NSArray *)pictures imageType:(BOOL)isGif;

/**
 *  发送视频信息,支持多张图片
 *
 *  @param chatBar
 *  @param videos 需要发送的视频信息
 */
- (void)chatBar:(KeyboardView *)chatBar sendVideos:(NSArray *)videos;

/**
 *  发送地理位置信息
 *
 *  @param chatBar
 *  @param locationCoordinate 需要发送的地址位置经纬度
 *  @param locationText       需要发送的地址位置对应信息
 */
- (void)chatBar:(KeyboardView *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText;

/**
 *  发送普通的文字信息,可能带有表情
 *
 *  @param chatBar
 *  @param message 需要发送的文字信息
 */
- (void)chatBar:(KeyboardView *)chatBar sendMessage:(NSString *)message;

/**
 *  音视频呼叫
 *
 *  @param chatBar
 *  @param calltime 呼叫时长，单位为秒
 *  @param isVideo  NO:音频呼叫; YES:视频呼叫
 */
- (void)chatBar:(KeyboardView *)chatBar sendCall:(NSString *)calltime withVideo:(BOOL)isVideo;

/**
 *  发送语音信息
 *
 *  @param chatBar
 *  @param voiceData 语音data数据
 *  @param seconds   语音时长
 */
- (void)chatBar:(KeyboardView *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds;

@end