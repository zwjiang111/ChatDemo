//
//  ChatListController.m
//  SpotGoods
//
//  Created by zhiwen jiang on 16/3/21.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import "ChatListController.h"
#import "ChatViewController.h"
#import "ChatListCell.h"
#import "Masonry.h"

@interface ChatListController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *networkStateView;
@property (strong, nonatomic) NSMutableArray *dataArray;

@property (copy, nonatomic, readonly) NSArray *thumbs;
@property (copy, nonatomic, readonly) NSArray *nickNames;

@end

@implementation ChatListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsCompact];
    
    self.navigationItem.title = @"聊天Demo";
    
    self.dataArray = [NSMutableArray array];
    
    [self.view addSubview:self.tableView];
    
    [self.view updateConstraintsIfNeeded];
    
    [self loadDatas];
}


- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make)
     {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top).with.offset(4);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatListCell"];
    cell.headImageView.image = [UIImage imageNamed:@"test_send"];
    [cell.titleLabel setText:self.dataArray[indexPath.row][@"nickName"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *chatC;
    if (indexPath.row == self.dataArray.count - 1)
    {
        chatC =[[ChatViewController alloc] initWithChatType:MessageChatGroup];
    }
    else
    {
        chatC = [[ChatViewController alloc] init];
    }
    chatC.strChatterName           = self.dataArray[indexPath.row][@"nickName"];
    chatC.strChatterThumb          = self.dataArray[indexPath.row][@"thumb"];
    chatC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatC animated:YES];
   // chatC.hidesBottomBarWhenPushed = NO;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - 私有方法

- (void)loadDatas
{
    self.dataArray = [NSMutableArray array];
    [self.thumbs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [self.dataArray addObject:@{@"nickName":self.nickNames[idx],@"thumb":obj}];
    }];
    [self.tableView reloadData];
}


#pragma mark - Getters方法

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"ChatListCell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}

- (UIView *)networkStateView
{
    if (!_networkStateView)
    {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        _networkStateView.backgroundColor = [UIColor orangeColor];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageSendFail"]];
        [_networkStateView addSubview:iconImageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.text = @"世界上最遥远的距离就是没网.检查设置";
        [_networkStateView addSubview:label];
        
        UIImageView *arrwoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_center_arrow_right"]];
        [_networkStateView addSubview:arrwoImageView];
        
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.left.equalTo(_networkStateView.mas_left).with.offset(4);
            make.centerY.equalTo(_networkStateView.mas_centerY);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.left.equalTo(iconImageView.mas_right).with.offset(4);
            make.centerY.equalTo(_networkStateView.mas_centerY);
        }];
        
        [arrwoImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.right.equalTo(_networkStateView.mas_right).with.offset(-8);
            make.centerY.equalTo(_networkStateView.mas_centerY);
        }];
        
    }
    return _networkStateView;
}

- (NSArray *)nickNames
{
    return @[@"小顾",@"小白"];
}

- (NSArray *)thumbs
{
    return @[@"test_send.png",@"test_send.png",];
}


@end
