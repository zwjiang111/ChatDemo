//
//  FacePageView.m
//
//  预览表情显示的View
//
//  Created by zhiwen jiang on 16/3/23.
//  Copyright © 2016年 FRITT. All rights reserved.
//

#import "FacePageView.h"
#import "FaceManager.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface FacePreviewView : UIView

@property (weak, nonatomic) UIImageView *faceImageView       /**< 展示face表情的 */;
@property (weak, nonatomic) UIImageView *backgroundImageView /**< 默认背景 */;

@end

@implementation FacePreviewView

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
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"preview_background"]];
    [self addSubview:self.backgroundImageView = backgroundImageView];
    
    UIImageView *faceImageView = [[UIImageView alloc] init];
    [self addSubview:self.faceImageView = faceImageView];
    
    self.bounds = self.backgroundImageView.bounds;
}

/**
 *  修改faceImageView显示的图片
 *
 *  @param image 需要显示的表情图片
 */
- (void)setFaceImage:(UIImage *)image
{
    if (self.faceImageView.image == image)
    {
        return;
    }
    
    [self.faceImageView setImage:image];
    [self.faceImageView sizeToFit];
    self.faceImageView.center = self.backgroundImageView.center;
    [UIView animateWithDuration:.3 animations:^
    {
        self.faceImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
    }
    completion:^(BOOL finished)
    {
        [UIView animateWithDuration:.2 animations:^
        {
            self.faceImageView.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end

@interface FacePageView ()

@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) FacePreviewView *facePreviewView;

@end

@implementation FacePageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        self.imageViewArray = [NSMutableArray array];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
        self.userInteractionEnabled = YES;
        [self setup];
    }
    return self;
}

#pragma mark - 私有方法

- (void)setup
{
    //判断是否需要重新添加所有的imageView
    if (self.imageViewArray && self.imageViewArray.count >= self.dataArray.count)
    {
        for (UIImageView *imageView in self.imageViewArray)
        {
            NSUInteger index = [self.imageViewArray indexOfObject:imageView];
            imageView.hidden = index >= self.dataArray.count;
            if (!imageView.hidden)
            {
                NSDictionary *faceDict = self.dataArray[index];
                NSString *faceImageName = [FaceManager faceImageNameWithFaceID:[faceDict[kFaceIDKey] integerValue]];
                imageView.tag = [faceDict[kFaceIDKey] integerValue];
                imageView.image = [UIImage imageNamed:faceImageName];
            }
        }
    }
    else
    {
        CGFloat itemWidth = (self.frame.size.width - 40) / self.columnsPerRow;
        CGFloat itemHeight = (self.frame.size.height-20) / self.maxRows;
        NSUInteger currentColumn = 0;
        NSUInteger currentRow = 0;
        for (NSDictionary *faceDict in self.dataArray)
        {
            if (currentColumn >= self.columnsPerRow)
            {
                currentRow ++ ;
                currentColumn = 0;
            }
            //计算每一个图片的起始X位置 10(左边距) + 第几列*itemWidth + 第几页*一页的宽度
            CGFloat startX = 20 + currentColumn * itemWidth;
            //计算每一个图片的起始Y位置  第几行*每行高度
            CGFloat startY = currentRow * itemHeight;

            if ([faceDict[kFaceIDKey] integerValue] >= 200)
            {
                NSString *strFaceImageName = [FaceManager faceImageNameWithFaceID:[faceDict[kFaceIDKey] integerValue]];
                NSString *strBundlePath =  [[NSBundle mainBundle]pathForResource:@"gifface" ofType:@"bundle"];
                NSString *strLocalPath = [[NSBundle bundleWithPath:strBundlePath] pathForResource:strFaceImageName ofType:@"gif"];
                FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(startX, startY, itemWidth, itemHeight)];
                
                imageView.userInteractionEnabled = YES;
                FLAnimatedImage *animationImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:strLocalPath]];
                imageView.animatedImage = animationImage;
                imageView.tag = [faceDict[kFaceIDKey] integerValue];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                [imageView addGestureRecognizer:tap];
                
                [self addSubview:imageView];
                [self.imageViewArray addObject:imageView];
            }
            else
            {
                UIImageView *imageView = [self faceImageViewWithID:faceDict[kFaceIDKey]];
                [imageView setFrame:CGRectMake(startX, startY, itemWidth, itemHeight)];
                [self addSubview:imageView];
                [self.imageViewArray addObject:imageView];
            }
            currentColumn ++ ;
        }
    }
}

/**
 *  根据faceID获取一个imageView实例
 *
 *  @param faceID faceID
 *
 *  @return
 */
- (UIImageView *)faceImageViewWithID:(NSString *)faceID
{
    NSString *faceImageName = [FaceManager faceImageNameWithFaceID:[faceID integerValue]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:faceImageName]];
    imageView.userInteractionEnabled = YES;
    imageView.tag = [faceID integerValue];
    imageView.contentMode = UIViewContentModeCenter;
    
    //添加图片的点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [imageView addGestureRecognizer:tap];
    
    return imageView;
}

/**
 *  根据点击位置获取点击的imageView
 *
 *  @param point 点击的位置
 *
 *  @return 被点击的imageView
 */
- (UIImageView *)faceViewWitnInPoint:(CGPoint)point
{
    for (UIImageView *imageView in self.imageViewArray)
    {
        if (CGRectContainsPoint(imageView.frame, point))
        {
            return imageView;
        }
    }
    return nil;
}

#pragma mark - Response Methods

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedFaceImageWithFaceID:)])
    {
        [self.delegate selectedFaceImageWithFaceID:tap.view.tag];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    CGPoint touchPoint = [longPress locationInView:self];
    CGPoint windowPoint = [longPress locationInView:[UIApplication sharedApplication].keyWindow];
    UIImageView *touchFaceView = [self faceViewWitnInPoint:touchPoint];
    
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        [self.facePreviewView setCenter:CGPointMake(windowPoint.x, windowPoint.y - 40)];
        [self.facePreviewView setFaceImage:touchFaceView.image];
        [[UIApplication sharedApplication].keyWindow addSubview:self.facePreviewView];
    }
    else if (longPress.state == UIGestureRecognizerStateChanged)
    {
        [self.facePreviewView setCenter:CGPointMake(windowPoint.x, windowPoint.y - 40)];
        [self.facePreviewView setFaceImage:touchFaceView.image];
    }
    else if (longPress.state == UIGestureRecognizerStateEnded)
    {
        [self.facePreviewView removeFromSuperview];
    }
}

#pragma mark - Getters方法

- (FacePreviewView *)facePreviewView
{
    if (!_facePreviewView)
    {
        _facePreviewView = [[FacePreviewView alloc] initWithFrame:CGRectZero];
    }
    return _facePreviewView;
}

#pragma mark - Setters方法

- (void)setDataArray:(NSArray *)datas
{
    _dataArray = [datas copy];
    [self setup];
}

- (void)setColumnsPerRow:(NSUInteger)columnsPerRow
{
    if (_columnsPerRow != columnsPerRow)
    {
        _columnsPerRow = columnsPerRow;
        [self.imageViewArray removeAllObjects];
        for (UIView *subView in self.subviews)
        {
            [subView removeFromSuperview];
        }
    }
}

@end
