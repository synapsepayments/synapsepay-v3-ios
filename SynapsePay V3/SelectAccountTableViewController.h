//
//  SelectAccountTableViewController.h
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/26/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAccountTableViewController : UITableViewController
@property (strong, nonatomic) NSMutableArray* users;
@property (strong, nonatomic) NSString* email;
@end
