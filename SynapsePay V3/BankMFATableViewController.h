//
//  BankMFATableViewController.h
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/23/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankMFATableViewController : UITableViewController
@property (strong, nonatomic) NSMutableDictionary* selectedBank;
@property (strong, nonatomic) NSMutableDictionary* nodeInfo;
@end
