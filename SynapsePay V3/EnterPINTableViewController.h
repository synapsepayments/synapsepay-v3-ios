//
//  EnterPINTableViewController.h
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/26/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterPINTableViewController : UITableViewController
@property (strong, nonatomic) NSMutableDictionary* user;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* phoneNumber;
@end
