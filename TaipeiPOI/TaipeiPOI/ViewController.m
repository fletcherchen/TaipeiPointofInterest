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
@property (strong, nonatomic) NSMutableArray <POIModel*>* dataSource;
@property (strong, nonatomic) NSDictionary *resultsDict;
@property (strong, nonatomic) NSMutableArray *catArray;
@property (strong, nonatomic) NSMutableArray *dataArray;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    POITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"POICell" forIndexPath:indexPath];
    
    NSURL* url = [NSURL URLWithString:self.dataSource[indexPath.row].file];
    [cell.thumbnailImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    cell.titleLabel.text = self.dataSource[indexPath.row].stitle;
    cell.bodyLabel.text = self.dataSource[indexPath.row].xbody;
    
    return cell;
}
#pragma mark - IBAction

- (IBAction)singleClassPressed:(id)sender {
    [UIAlertController showWithController:self
                              cancelTitle:@"Cancel"
                                     type:UIAlertControllerStyleActionSheet
                                    title:@"Category"
                                  message:@"Please choose one category"
                                  buttons:self.resultsDict.allKeys complete:^(NSInteger buttonIndex) {
                                      //cancel
                                      if (buttonIndex == -1) {
                                          //do nothing
                                          return;
                                      }
                                      
                                      self.currentCategory = self.resultsDict.allKeys[buttonIndex];
                                      [self.tableView reloadData];
                                  }];
}
- (IBAction)allValuesBtnPressed:(UIButton *)sender {
    self.currentCategory = kAllValues;
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

-(NSMutableArray *)catArray{
    if (!_catArray) {
        _catArray = [[NSMutableArray alloc]init];
    }
    return _catArray;
}

-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    
    return _dataArray;
}

-(NSDictionary *)resultsDict {
    if (!_resultsDict) {
        _resultsDict = [[NSDictionary alloc]init];
    }
    
    return _resultsDict;
}

-(NSMutableArray <POIModel*>*)dataSource {
    return self.resultsDict[self.currentCategory];
}

-(UIRefreshControl*)refreshControl {
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(shouldRefresh:) forControlEvents:UIControlEventValueChanged];
    
    return refreshControl;
}

@end
