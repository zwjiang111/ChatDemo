//
//  RecordView.h
//
//  录音加载的指示器
//
//  Created by zhiwen jiang on 16/4/25.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RecordView : UIView

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

@end
