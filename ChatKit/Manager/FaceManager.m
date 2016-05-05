//
//  FaceManager.m
//
//
//  Created by zhiwen jiang on 16/4/22.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import "FaceManager.h"

@interface FaceManager ()

@property (strong, nonatomic) NSMutableArray *emojiFaceArrays;
@property (strong, nonatomic) NSMutableArray *recentFaceArrays;
@property (strong, nonatomic) NSMutableArray *gifFaceArrays;
@end

@implementation FaceManager

- (instancetype)init
{
    if (self = [super init])
    {
        _emojiFaceArrays = [NSMutableArray array];
        _gifFaceArrays = [NSMutableArray array];
        
        NSArray *faceArray = [NSArray arrayWithContentsOfFile:[FaceManager defaultEmojiFacePath]];
        [_emojiFaceArrays addObjectsFromArray:faceArray];
        
        NSArray *gifFaceArray = [NSArray arrayWithContentsOfFile:[FaceManager defaultGifFacePath]];
        [_gifFaceArrays addObjectsFromArray:gifFaceArray];

        NSArray *recentArrays = [[NSUserDefaults standardUserDefaults] arrayForKey:@"recentFaceArrays"];
        if (recentArrays)
        {
            _recentFaceArrays = [NSMutableArray arrayWithArray:recentArrays];
        }
        else
        {
            _recentFaceArrays = [NSMutableArray array];
        }
        
    }
    return self;
}


+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id shareInstance;
    dispatch_once(&onceToken, ^
    {
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}


#pragma mark - Emoji相关表情处理方法

+ (NSArray *)emojiFaces
{
    return [[FaceManager shareInstance] emojiFaceArrays];
}

+ (NSArray *)gifFaces
{
    return [[FaceManager shareInstance] gifFaceArrays];
}

+ (NSString *)defaultEmojiFacePath
{
    return [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
}

+ (NSString *)defaultGifFacePath
{
    return [[NSBundle mainBundle] pathForResource:@"gifface" ofType:@"plist"];
}

+ (NSString *)faceImageNameWithFaceID:(NSUInteger)faceID
{
    if (faceID == 999)
    {
        return @"[删除]";
    }
    
    for (NSDictionary *faceDict in [[FaceManager shareInstance] emojiFaceArrays])
    {
        if ([faceDict[kFaceIDKey] integerValue] == faceID)
        {
            return faceDict[kFaceImageNameKey];
        }
    }
    
    for (NSDictionary *faceDict in [[FaceManager shareInstance] gifFaceArrays])
    {
        if ([faceDict[kFaceIDKey] integerValue] == faceID)
        {
            return faceDict[kFaceImageNameKey];
        }
    }
    return @"";
}

+ (NSString *)faceNameWithFaceID:(NSUInteger)faceID
{
    if (faceID == 999)
    {
        return @"[删除]";
    }
    
    for (NSDictionary *faceDict in [[FaceManager shareInstance] emojiFaceArrays])
    {
        if ([faceDict[kFaceIDKey] integerValue] == faceID)
        {
            return faceDict[kFaceNameKey];
        }
    }
    
    for (NSDictionary *faceDict in [[FaceManager shareInstance] gifFaceArrays])
    {
        if ([faceDict[kFaceIDKey] integerValue] == faceID)
        {
            return faceDict[kFaceNameKey];
        }
    }

    return @"";
}

+ (NSMutableAttributedString *)emotionStrWithString:(NSString *)strText
{
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:strText];
    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情
    
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re)
    {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }
    
    NSArray *resultArray = [re matchesInString:strText options:0 range:NSMakeRange(0, strText.length)];
    //3、获取所有的表情以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray)
    {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [strText substringWithRange:range];
        
        for (NSDictionary *dict in [[FaceManager shareInstance] emojiFaceArrays])
        {
            if ([dict[kFaceNameKey]  isEqualToString:subStr])
            {
                //face[i][@"png"]就是我们要加载的图片
                //新建文字附件来存放我们的图片,iOS7才新加的对象
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                //给附件添加图片
                textAttachment.image = [UIImage imageNamed:dict[kFaceImageNameKey]];
                //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
                textAttachment.bounds = CGRectMake(0, -8, textAttachment.image.size.width, textAttachment.image.size.height);
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //把字典存入数组中
                [imageArray addObject:imageDic];
                break;
            }
        }
    }
    
    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--)
    {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    return attributeString;
}


#pragma mark - 最近使用表情相关方法
/**
 *  获取最近使用的表情图片
 *
 *  @return
 */
+ (NSArray *)recentFaces
{
    return [[FaceManager shareInstance] recentFaceArrays];
}


+ (BOOL)saveRecentFace:(NSDictionary *)recentDict
{
    for (NSDictionary *dict in [[FaceManager shareInstance] recentFaceArrays])
    {
        if ([dict[@"face_id"] integerValue] == [recentDict[@"face_id"] integerValue])
        {
            NSLog(@"已经存在");
            return NO;
        }
    }
    
    [[[FaceManager shareInstance] recentFaceArrays] insertObject:recentDict atIndex:0];
    if ([[FaceManager shareInstance] recentFaceArrays].count > 16)
    {
        [[[FaceManager shareInstance] recentFaceArrays] removeLastObject];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[[FaceManager shareInstance] recentFaceArrays] forKey:@"recentFaceArrays"];
    return YES;
}

@end
