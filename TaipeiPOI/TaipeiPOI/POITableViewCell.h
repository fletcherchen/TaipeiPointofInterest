//
//  POITableViewCell.h
//  TaipeiPOI
//
//  Created by Jeng-Wei Chen on 11/3/16.
//  Copyright © 2016 Jeng-Wei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POITableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView* thumbnailImageView;
@property (strong, nonatomic) IBOutlet UILabel *bodyLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@end
