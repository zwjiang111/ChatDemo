//
//  LocationViewController.h
//
//
//  Created by zhiwen jiang on 16/4/15.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@protocol LocationViewControllerDelegate <NSObject>

- (void)cancelLocation;
- (void)sendLocation:(CLPlacemark *)placemark;

@end

/**
 *  选择地理位置
 */
@interface LocationViewController : UIViewController

@property (weak, nonatomic) id<LocationViewControllerDelegate> delegate;

@end
