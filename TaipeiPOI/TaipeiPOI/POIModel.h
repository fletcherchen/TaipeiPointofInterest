//
//  POIModel.h
//  TaipeiPOI
//
//  Created by Jeng-Wei Chen on 10/27/16.
//  Copyright © 2016 Jeng-Wei Chen. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface POIModel : JSONModel

@property (nonatomic) NSString *CAT2;
@property (nonatomic) NSString *stitle;
@property (nonatomic) NSString *xbody;
@property (nonatomic) NSString<Optional> *file;

@end
