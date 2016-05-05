//
//  LocationViewController.m
//
//  Created by zhiwen jiang on 16/4/15.
//  Copyright (c) 2016年 FRITT. All rights reserved.
//

#import "LocationViewController.h"

#import "Masonry.h"

@interface LocationViewController ()<UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MKMapView *mapView;

@property (strong, nonatomic) UIButton *showUserLocationButton;
@property (strong, nonatomic) UIImageView *locationImageView;

@property (strong, nonatomic) NSMutableArray *placemarkArray;
@property (assign, nonatomic) BOOL isFirstLocateUser;

@property (weak, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation LocationViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(sendLocation)];
    self.placemarkArray = [NSMutableArray array];
    self.isFirstLocateUser = YES;
    [self.mapView addSubview:self.locationImageView];
    [self.mapView addSubview:self.showUserLocationButton];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.tableView];
    [[LocationManager shareManager] requestAuthorization];
    [self.view updateConstraintsIfNeeded];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.locationImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.centerX.equalTo(self.mapView.mas_centerX);
        make.centerY.equalTo(self.mapView.mas_centerY);
    }];
    
    [self.showUserLocationButton mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.mapView.mas_left).with.offset(8);
        make.bottom.equalTo(self.mapView.mas_bottom).with.offset(-8);
    }];
    
    [self.mapView mas_remakeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.height.mas_equalTo([[UIScreen mainScreen] bounds].size.height-200);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.mapView.mas_bottom);
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
    return self.placemarkArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    if (indexPath.row == self.selectedIndexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (indexPath.row >= self.placemarkArray.count)
    {
        return cell;
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"[位置] \n%@",[self.placemarkArray[indexPath.row] name]];
    }
    else
    {
        cell.textLabel.text = [self.placemarkArray[indexPath.row] name];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndexPath = indexPath;
    [tableView reloadData];
}

#pragma mark - MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if (!self.isFirstLocateUser)
    {
        return;
    }
    [mapView setShowsUserLocation:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.isFirstLocateUser = NO;
    [self showUserLocation];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!animated)
    {
        self.showUserLocationButton.selected = NO;
        [self updateCenterLocation:mapView.centerCoordinate];
    }
}

#pragma mark - 私有方法

/**
 *  搜索附近兴趣点信息
 *
 *  @param coordinate 搜索的点
 */
- (void)searchNearBy:(CLLocationCoordinate2D)coordinate
{
    //创建一个位置信息对象，第一个参数为经纬度，第二个为纬度检索范围，单位为米，第三个为经度检索范围，单位为米
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
    //初始化一个检索请求对象
    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc]init];
    //设置检索参数
    req.region=region;
    //兴趣点关键字
    req.naturalLanguageQuery = @"market";
    //初始化检索
    MKLocalSearch * ser = [[MKLocalSearch alloc]initWithRequest:req];
    //开始检索，结果返回在block中
    [ser startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        //兴趣点节点数组
        NSArray * array = [NSArray arrayWithArray:response.mapItems];
        for (MKMapItem *mapItem in array)
        {
            [self.placemarkArray addObject:mapItem.placemark];
        }
        [self.tableView reloadData];
    }];
}

/**
 *  更新mapView中心点
 *
 *
 *  @param centerCoordinate 中心点经纬度
 */
- (void)updateCenterLocation:(CLLocationCoordinate2D)centerCoordinate
{
    MKCoordinateSpan span;
    span.latitudeDelta=0.001;
    span.longitudeDelta=0.001;
    MKCoordinateRegion region = {centerCoordinate,span};
    [self.mapView setRegion:region animated:YES];
    
    [self.placemarkArray removeAllObjects];
    
    [[LocationManager shareManager] reverseGeocodeWithCoordinate2D:centerCoordinate success:^(NSArray *placemarks)
     {
        [self.placemarkArray addObjectsFromArray:placemarks];
        [self searchNearBy:centerCoordinate];
    }
    failure:^
    {
        [self searchNearBy:centerCoordinate];
    }];
    
}

- (void)showUserLocation
{
    self.showUserLocationButton.selected = YES;
    [self updateCenterLocation:self.mapView.userLocation.coordinate];
}

- (void)cancel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelLocation)])
    {
        [self.delegate cancelLocation];
    }
}

- (void)sendLocation
{
    if (self.placemarkArray.count > self.selectedIndexPath.row)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendLocation:)])
        {
            [self.delegate sendLocation:self.placemarkArray[self.selectedIndexPath.row]];
        }
    }
}

#pragma mark - Getters方法

- (MKMapView *)mapView
{
    if (!_mapView)
    {
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
    }
    return _mapView;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 200) style:UITableViewStylePlain];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor redColor];
    }
    return _tableView;
}

- (UIButton *)showUserLocationButton
{
    if (!_showUserLocationButton)
    {
        _showUserLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_showUserLocationButton setBackgroundImage:[UIImage imageNamed:@"show_user_location_normal"] forState:UIControlStateNormal];
        [_showUserLocationButton setBackgroundImage:[UIImage imageNamed:@"show_user_location_pressed"] forState:UIControlStateHighlighted];
        [_showUserLocationButton setBackgroundImage:[UIImage imageNamed:@"show_user_location_selected"] forState:UIControlStateSelected];
        [_showUserLocationButton addTarget:self action:@selector(showUserLocation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showUserLocationButton;
}

- (UIImageView *)locationImageView
{
    if (!_locationImageView)
    {
        _locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location_green_icon"]];
    }
    return _locationImageView;
}

@end
