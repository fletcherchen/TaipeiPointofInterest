//
//  ViewController.m
//  TaipeiPOI
//
//  Created by Jeng-Wei Chen on 10/27/16.
//  Copyright © 2016 Jeng-Wei Chen. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "POIModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150.0f;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    [self getPOIList];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPOIList {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *url = @"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=36847f3f-deff-4183-a5bb-800737591de5";
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        self.dataSource = [POIModel arrayOfModelsFromDictionaries:responseObject[@"result"][@"results"] error:&error];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark -TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIndentifier = @"POICell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    
    //Config Cell
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[self.dataSource[indexPath.row] file]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    UILabel *title = (UILabel *)[cell viewWithTag:102];
    title.text = [self.dataSource[indexPath.row] stitle];
    
    UILabel *body = (UILabel *)[cell viewWithTag:103];
    body.text = [self.dataSource[indexPath.row] xbody];
    
    return cell;
}

@end
