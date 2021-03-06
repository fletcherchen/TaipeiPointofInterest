//
//  ViewController.m
//  TaipeiPOI
//
//  Created by Jeng-Wei Chen on 10/27/16.
//  Copyright © 2016 Jeng-Wei Chen. All rights reserved.
//

#import "ViewController.h"
#import "POIModel.h"
#import "POITableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <LOAlertController/UIAlertController+LOAlertController.h>
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

#define kAllValues @"AllValues"

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray <NSArray <POIModel*>*>* dataSource;
@property (strong, nonatomic) NSDictionary *resultsDict;
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSString* currentCategory;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentCategory = kAllValues;

    [self setUpTableView];
    [self getPOIListComplete:nil];
}

-(void)shouldRefresh:(UIRefreshControl*)refreshControl {
    [self getPOIListComplete:^{
        [refreshControl endRefreshing];
    }];
}

#pragma mark - UITableViewDelegate UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    POITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"POICell" forIndexPath:indexPath];
    
    NSURL* url = [NSURL URLWithString:self.dataSource[indexPath.section][indexPath.row].file];
    
    cell.thumbnailImageView.image = nil;
    [cell.thumbnailImageView sd_setImageWithURL:url];
    
    cell.titleLabel.text = self.dataSource[indexPath.section][indexPath.row].stitle;
    cell.bodyLabel.text = self.dataSource[indexPath.section][indexPath.row].xbody;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.dataSource[section].count) {
        return self.dataSource[section][0].CAT2;
    }
    return 0;
}

#pragma mark - IBAction

- (IBAction)singleClassPressed:(id)sender {

    [UIAlertController showWithController:self
                              cancelTitle:@"Cancel"
                                     type:UIAlertControllerStyleActionSheet
                                    title:@"Category"
                                  message:@"Please choose one category"
                                  buttons:[self categoriesWithoutAllValues]
                                 complete:^(NSInteger buttonIndex) {
                                      //cancel
                                      if (buttonIndex == -1) {
                                          //do nothing
                                          return;
                                      }
                                      
                                      self.currentCategory = self.resultsDict.allKeys[buttonIndex];
                                      [self scrollToTopAndReload];
                                  }];
}

- (IBAction)allValuesBtnPressed:(UIButton *)sender {
    self.currentCategory = kAllValues;
    [self scrollToTopAndReload];
}

-(void)scrollToTopAndReload {
    self.tableView.contentOffset = CGPointMake(0, 0);
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
}

#pragma mark - methods

- (void)getPOIListComplete:(void(^)(void))complete {
    NSString *url = @"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=36847f3f-deff-4183-a5bb-800737591de5";
    
    [SVProgressHUD show];
    [self.manager GET:url
           parameters:nil
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
                  NSArray* results = [POIModel arrayOfModelsFromDictionaries:responseObject[@"result"][@"results"]
                                                                    error:nil];
                  
                  self.resultsDict = [self matchArrayWithString:results];
                  [self.tableView reloadData];
                  [SVProgressHUD dismiss];
                  
                  if (complete) {
                      complete();
                  }
                  
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        if (complete) {
            complete();
        }
    }];
}

- (NSMutableArray *)categoriesWithoutAllValues {
    NSMutableArray *categoies = [NSMutableArray arrayWithArray:self.resultsDict.allKeys];
    [categoies removeObject:kAllValues];
    return categoies;
}

- (NSDictionary *)matchArrayWithString:(NSArray <POIModel *>*)models {
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc]init];

    for (POIModel *model in models) {
        if (!results[kAllValues]) {
            results[kAllValues] = [[NSMutableArray alloc]init];
        }
        
        if (!results[model.CAT2]) {
            results[model.CAT2] = [[NSMutableArray alloc]init];
        }

        [results[kAllValues] addObject:model];
        [results[model.CAT2] addObject:model];
    }

    return results;
}

-(void)setUpTableView {
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150.0f;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.refreshControl = [self refreshControl];
}

#pragma mark - getters & setters

-(AFHTTPSessionManager *)manager {
    return [AFHTTPSessionManager manager];
}

-(NSDictionary *)resultsDict {
    if (!_resultsDict) {
        _resultsDict = [[NSDictionary alloc]init];
    }
    
    return _resultsDict;
}

-(NSMutableArray <NSArray <POIModel*>*>*)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    
    [_dataSource removeAllObjects];
    
    if (!self.resultsDict[self.currentCategory]) {
        return _dataSource;
    }
    
    if ([self.currentCategory isEqualToString:kAllValues]) {
        [self.resultsDict enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSArray <POIModel*>*  _Nonnull obj, BOOL * _Nonnull stop) {
            [_dataSource addObject:obj];
        }];
        
        return _dataSource;
    }
    
    [_dataSource addObject:self.resultsDict[self.currentCategory]];
    
    return _dataSource;
}

-(UIRefreshControl*)refreshControl {
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(shouldRefresh:) forControlEvents:UIControlEventValueChanged];
    
    return refreshControl;
}

@end
