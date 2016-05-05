//
//  ContentView.m
//
//  Created by zhiwen jiang on 16/4/7.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "ContentView.h"

@implementation ContentView

- (instancetype)init
{
    if ([super init])
    {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor clearColor].CGColor;
        maskLayer.contentsCenter = CGRectMake(.7f, .7f, .1f, .1f);
        maskLayer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.mask = maskLayer;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.maskView.frame = CGRectInset(self.bounds, 0, 0);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    self.layer.mask.frame = CGRectInset(self.bounds, 0, 0);
}

@end
