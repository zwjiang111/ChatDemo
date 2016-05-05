//
//  RecordView.m
//
//  Created by zhiwen jiang on 16/4/25.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import "RecordView.h"
#import "masonry.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordView ()
{
    NSURL *_recordUrl;
    NSTimer *_timer;
    AVAudioRecorder *_audioRecorder;
}

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIImageView *recordImageView;
@property (strong, nonatomic) UIImageView *yinjieImageView;
@property (strong, nonatomic) UIView *maskView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation RecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    _recordUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"record.caf"]];
    NSError *error;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:_recordUrl settings:recordSetting error:&error];
    _audioRecorder.meteringEnabled = YES;
    
    [self addSubview:self.recordImageView];
    [self addSubview:self.yinjieImageView];
    [self addSubview:self.maskView];
    [self addSubview:self.titleLabel];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make)
     {
         make.width.mas_equalTo (@(140));
         make.height.mas_equalTo (@(140));
     }];

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.height.mas_equalTo(@(16));
        make.bottom.equalTo(self.mas_bottom).with.offset(-5);
    }];
    
    [self.recordImageView mas_remakeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self.mas_centerX).with.offset(-20);
         make.centerY.equalTo(self.mas_centerY).with.offset(0);
         make.height.equalTo(self.mas_height).with.offset(-20);
     }];
    
    [self.yinjieImageView mas_remakeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.recordImageView.mas_right).with.offset(10);
         make.bottom.equalTo(self.recordImageView.mas_bottom).with.offset(0);
         make.height.equalTo(self.mas_height).with.offset(-80);
     }];

//    [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make)
//     {
//         make.left.equalTo(self.recordImageView.mas_right).with.offset(10);
//         make.top.equalTo(self.yinjieImageView.mas_top).with.offset(0);
//        // make.height.mas_equalTo(0);
//     }];
}

#pragma mark - 私有方法
- (void)changeImage
{
    [_audioRecorder updateMeters];//更新测量值
    float avg = [_audioRecorder averagePowerForChannel:0];
    float minValue = -60;
    float range = 60;
    float outRange = 100;
    if (avg < minValue)
    {
        avg = minValue;
    }
    float decibels = (avg + range) / range * outRange;
    
    [self.maskView mas_updateConstraints:^(MASConstraintMaker *make)
     {
         make.height.mas_equalTo( _yinjieImageView.frame.size.height - decibels * _yinjieImageView.frame.size.height/100);
     }];
    
    _maskView.layer.frame = CGRectMake(0,
                                       _yinjieImageView.frame.size.height - decibels * _yinjieImageView.frame.size.height / 100,
                                       _yinjieImageView.frame.size.width,
                                       _yinjieImageView.frame.size.height);
    [_yinjieImageView.layer setMask:_maskView.layer];
}

#pragma mark - 公有方法

- (void)startRecordVoice
{
    [_audioRecorder deleteRecording];
    [_audioRecorder record];
    self.hidden = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                              target:self
                                            selector:@selector(changeImage)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)cancelRecordVoice
{
    [_timer invalidate];
    _timer = nil;
    self.hidden = YES;
    [_audioRecorder stop];
}

- (void)endRecordVoice
{
    [_timer invalidate];
    _timer = nil;
    self.hidden = YES;
    [_audioRecorder stop];
}

- (void)updateCancelRecordVoice
{
    _yinjieImageView.hidden = YES;
    _titleLabel.text = @"松开手指，取消发送";
    _titleLabel.backgroundColor = [UIColor clearColor];
    _recordImageView.image = [UIImage imageNamed:@"chexiao"];
    [self.recordImageView mas_remakeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self.mas_centerX).with.offset(0);
         make.centerY.equalTo(self.mas_centerY).with.offset(0);
     }];
}

- (void)updateContinueRecordVoice
{
    _yinjieImageView.hidden = NO;
    _titleLabel.backgroundColor = [UIColor redColor];
    _titleLabel.text = @"手指上滑，取消发送";
    _recordImageView.image = [UIImage imageNamed:@"yuyin"];
    [self.recordImageView mas_remakeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self.mas_centerX).with.offset(-20);
         make.centerY.equalTo(self.mas_centerY).with.offset(0);
     }];
}

#pragma mark - Getters方法
- (UIImageView *)recordImageView
{
    if (!_recordImageView)
    {
        _recordImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _recordImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _recordImageView.image = [UIImage imageNamed:@"yuyin"];
    }
    return _recordImageView;
}

- (UIImageView *)yinjieImageView
{
    if (!_yinjieImageView)
    {
        _yinjieImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _yinjieImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _yinjieImageView.image = [UIImage imageNamed:@"yinjie（6）"];
    }
    return _yinjieImageView;
}

- (UIView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.translatesAutoresizingMaskIntoConstraints = NO;
        _maskView.backgroundColor = [UIColor blueColor];
    }
    return _yinjieImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.backgroundColor = [UIColor redColor];
        _titleLabel.text = @"手指上滑，取消发送";
        _titleLabel.layer.cornerRadius = 5;
        _titleLabel.clipsToBounds = YES;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end
