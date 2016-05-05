//
//  ChatFaceView.m
//
//  Created by zhiwen jiang on 16/3/24.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import "ChatFaceView.h"
#import "FaceManager.h"
#import "SwipeView.h"
#import "FacePageView.h"


@interface ChatFaceView ()<UIScrollViewDelegate,SwipeViewDelegate,SwipeViewDataSource,FacePageViewDelegate>

@property (nonatomic, strong) SwipeView     *swipeView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *sendButton;

@property (weak, nonatomic) UIButton *recentButton /**< 显示最近表情的button */;
@property (weak, nonatomic) UIButton *emojiButton  /**< 显示emoji表情Button */;
@property (weak, nonatomic) UIButton *gifButton    /**< 显示gif表情Button */;
@property (weak, nonatomic) UILabel  *gifLabel;

@property (assign, nonatomic) NSUInteger columnPerRow; /**< 每行显示的表情数量,6,6plus可能相应多显示  默认emoji5s显示7个 最近表情显示4个  gif表情显示4个 */
@property (assign, nonatomic) NSUInteger maxRows;      /**< 每页显示的行数 默认emoji3行  最近表情2行  gif表情2行 */
@property (nonatomic, assign ,readonly) NSUInteger itemsPerPage;
@property (nonatomic, assign) NSUInteger pageCount;

@property (nonatomic, strong) NSMutableArray *faceArray;

@end

@implementation ChatFaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

#pragma mark - SwipeViewDelegate & SwipeViewDataSource

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    FacePageView *facePageView = (FacePageView *)view;
    if (!view)
    {
        facePageView = [[FacePageView alloc] initWithFrame:swipeView.frame];
    }
    [facePageView setColumnsPerRow:self.columnPerRow];
    [facePageView setMaxRows:self.maxRows];
    
    if ((index + 1) * self.itemsPerPage  >= self.faceArray.count)
    {
        [facePageView setDataArray:[self.faceArray subarrayWithRange:NSMakeRange(index * self.itemsPerPage, self.faceArray.count - index * self.itemsPerPage)]];
    }
    else
    {
        [facePageView setDataArray:[self.faceArray subarrayWithRange:NSMakeRange(index * self.itemsPerPage, self.itemsPerPage)]];
    }
    
    facePageView.delegate = self;
    return facePageView;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.pageCount ;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    self.pageControl.currentPage = swipeView.currentPage;
}

#pragma mark - FacePageViewDelegate

- (void)selectedFaceImageWithFaceID:(NSUInteger)faceID
{
    NSString *strFaceName = [FaceManager faceNameWithFaceID:faceID];
    if (faceID != 999)
    {
        [FaceManager saveRecentFace:@{@"face_id":[NSString stringWithFormat:@"%ld",faceID],@"face_name":strFaceName}];
    }
    
    if (faceID < 200)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)])
        {
            [self.delegate faceViewSendFace:strFaceName];
        }
    }
    else
    {
        NSString *strFaceImageName = [FaceManager faceImageNameWithFaceID:faceID];
        NSString *strBundlePath =  [[NSBundle mainBundle]pathForResource:@"gifface" ofType:@"bundle"];
        NSString *strLocalPath = [[NSBundle bundleWithPath:strBundlePath] pathForResource:strFaceImageName ofType:@"gif"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendGifFace:)])
        {
            [self.delegate faceViewSendGifFace:strLocalPath];
        }
    }
}

#pragma mark - 私有方法

- (void)setup
{
    [self addSubview:self.swipeView];
    [self addSubview:self.pageControl];
    [self addSubview:self.bottomView];
    
    self.faceArray = [NSMutableArray array];
    self.faceViewType = ShowEmojiFace;
    [self setupFaceView];
    
    self.userInteractionEnabled = YES;
}

- (void)setupFaceView
{
    [self.faceArray removeAllObjects];
    if (self.faceViewType == ShowEmojiFace)
    {
        [self setupEmojiFaces];
    }
    else if (self.faceViewType == ShowRecentFace)
    {
        [self setupRecentFaces];
    }
    else if (self.faceViewType == ShowGifFace)
    {
        [self setupGifFaces];
    }
    
    [self.swipeView reloadData];
    
}

/**
 *  初始化最近使用的表情数组
 */
- (void)setupRecentFaces
{
    self.maxRows = 2;
    self.columnPerRow = 8;
    self.pageCount = 1;
    
    [self.faceArray removeAllObjects];
    [self.faceArray addObjectsFromArray:[FaceManager recentFaces]];
}

/**
 *  初始化Gif表情数组
 */
- (void)setupGifFaces
{
    self.maxRows = 2;
    self.columnPerRow = 6;
    self.pageCount = 1;
    
    [self.faceArray removeAllObjects];
    [self.faceArray addObjectsFromArray:[FaceManager gifFaces]];
    
     NSInteger pageItemCount = self.itemsPerPage - 1;
     self.pageCount = [self.faceArray count] % pageItemCount == 0 ? [self.faceArray count] / pageItemCount : ([self.faceArray count] / pageItemCount) + 1;
    
    //配置pageControl的页数
    self.pageControl.numberOfPages = self.pageCount;
    
}
/**
 *  初始化所有的emoji表情数组,添加删除按钮
 */
- (void)setupEmojiFaces
{
    self.maxRows = 3;
    self.columnPerRow = [UIScreen mainScreen].bounds.size.width > 320 ? 8 : 7;
    
    //计算每一页最多显示多少个表情  - 1(删除按钮)
    NSInteger pageItemCount = self.itemsPerPage - 1;
    [self.faceArray addObjectsFromArray:[FaceManager emojiFaces]];
    //获取所有的face表情dict包含face_id,face_name两个key-value
    NSMutableArray *allFaceArray = [NSMutableArray arrayWithArray:[FaceManager emojiFaces]];
    
    //计算页数
    self.pageCount = [allFaceArray count] % pageItemCount == 0 ? [allFaceArray count] / pageItemCount : ([allFaceArray count] / pageItemCount) + 1;
    
    //配置pageControl的页数
    self.pageControl.numberOfPages = self.pageCount;
    
    //循环,给每一页末尾加上一个delete图片,如果是最后一页直接在最后一个加上delete图片
    for (int i = 0; i < self.pageCount; i++)
    {
        if (self.pageCount - 1 == i)
        {
            [self.faceArray addObject:@{@"face_id":@"999",@"face_name":@"删除"}];
        }
        else
        {
            [self.faceArray insertObject:@{@"face_id":@"999",@"face_name":@"删除"} atIndex:(i + 1) * pageItemCount + i];
        }
    }
}

- (void)sendAction:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)])
    {
        [self.delegate faceViewSendFace:@"发送"];
    }
}

- (void)changeFaceType
{
    self.faceViewType = self.gifButton.tag;
    [self setupFaceView];
}

- (void)changeFaceType:(UIButton *)button
{
    self.faceViewType = button.tag;
    [self setupFaceView];
}

#pragma mark - Setters方法

- (void)setFaceViewType:(ShowFaceViewType)faceViewType
{
    if (_faceViewType != faceViewType)
    {
        _faceViewType = faceViewType;
        self.emojiButton.selected = _faceViewType == ShowEmojiFace;
        self.gifButton.selected = _faceViewType == ShowGifFace;
        self.recentButton.selected = _faceViewType == ShowRecentFace;
    }
}

#pragma mark - Getters方法

- (SwipeView *)swipeView
{
    if (!_swipeView)
    {
        _swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height - 60)];
        _swipeView.delegate = self;
        _swipeView.dataSource = self;
    }
    return _swipeView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.swipeView.frame.size.height, self.frame.size.width, 20)];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

- (UIView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40)];
        
        UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 70, 1.0f)];
        topLine.backgroundColor = [UIColor lightGrayColor];
        [_bottomView addSubview:topLine];
        
        UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, 0, 70, 40)];
        sendButton.backgroundColor = [UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:1.0f];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:self.sendButton = sendButton];
        
        UIButton *recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [recentButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_normal"] forState:UIControlStateNormal];
        [recentButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_highlight"] forState:UIControlStateHighlighted];
        [recentButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_highlight"] forState:UIControlStateSelected];
        recentButton.tag = ShowRecentFace;
        [recentButton addTarget:self action:@selector(changeFaceType:) forControlEvents:UIControlEventTouchUpInside];
        [recentButton sizeToFit];
        [_bottomView addSubview:self.recentButton = recentButton];
        [recentButton setFrame:CGRectMake(0,
                                          _bottomView.frame.size.height/2-recentButton.frame.size.height/2,
                                          recentButton.frame.size.width,
                                          recentButton.frame.size.height)];
        
        UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_normal"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_highlight"] forState:UIControlStateHighlighted];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_highlight"] forState:UIControlStateSelected];
        emojiButton.tag = ShowEmojiFace;
        [emojiButton addTarget:self action:@selector(changeFaceType:) forControlEvents:UIControlEventTouchUpInside];
        [emojiButton sizeToFit];
        [_bottomView addSubview:self.emojiButton = emojiButton];
        [emojiButton setFrame:CGRectMake(recentButton.frame.size.width,
                                         _bottomView.frame.size.height/2-emojiButton.frame.size.height/2,
                                         emojiButton.frame.size.width,
                                         emojiButton.frame.size.height)];
        
        UIButton *gifButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [gifButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_face_normal"] forState:UIControlStateNormal];
        [gifButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_face_highlight"] forState:UIControlStateHighlighted];
        [gifButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_face_highlight"] forState:UIControlStateSelected];
        gifButton.tag = ShowGifFace;
        [gifButton addTarget:self action:@selector(changeFaceType:) forControlEvents:UIControlEventTouchUpInside];
        [gifButton sizeToFit];
        [_bottomView addSubview:self.gifButton=gifButton];
        [gifButton setFrame:CGRectMake(emojiButton.frame.size.width+recentButton.frame.size.width,
                                       _bottomView.frame.size.height/2-gifButton.frame.size.height/2,
                                       gifButton.frame.size.width,
                                       gifButton.frame.size.height)];
        
        UILabel *gifLabel = [[UILabel alloc] initWithFrame:CGRectMake(emojiButton.frame.size.width+recentButton.frame.size.width+30, 0, 80, 40)];
        gifLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        gifLabel.textColor = [UIColor grayColor];
        gifLabel.text = @"动画";
        gifLabel.userInteractionEnabled = YES;
        [_bottomView addSubview:self.gifLabel=gifLabel];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeFaceType)];
        [self.gifLabel addGestureRecognizer:tap];
        
    }
    return _bottomView;
}

/**
 *  每一页显示的表情数量 = M每行数量*N行
 */
- (NSUInteger)itemsPerPage
{
    return self.maxRows * self.columnPerRow;
}

@end
    