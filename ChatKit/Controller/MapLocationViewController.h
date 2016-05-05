//
//  MapLocationViewController.h
//
//
//  Created by zhiwen jiang on 16/5/4.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MyAnnoation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@interface MapLocationViewController : UIViewController

@property(nonatomic,strong) CLLocation *location;

@end
