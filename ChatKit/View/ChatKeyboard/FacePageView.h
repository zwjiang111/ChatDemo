//
//  FacePageView.h
//
//
//  Created by zhiwen jiang on 16/3/23.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FacePageViewDelegate <NSObject>

- (void)selectedFaceImageWithFaceID:(NSUInteger)faceID;

@end

@interface FacePageView : UIView

@property (nonatomic, assign) NSUInteger columnsPerRow;
@property (nonatomic, assign) NSUInteger maxRows;
@property (nonatomic, copy)   NSArray    *dataArray;
@property (nonatomic, weak) id<FacePageViewDelegate> delegate;

@end
