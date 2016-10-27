//
//  ViewController.h
//  TaipeiPOI
//
//  Created by Jeng-Wei Chen on 10/27/16.
//  Copyright © 2016 Jeng-Wei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSource;
@end

