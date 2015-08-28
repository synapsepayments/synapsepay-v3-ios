//
//  SelectNodeTableViewController.h
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/26/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectNodeTableDelegate <NSObject>
-(void)selectedNode:(NSMutableDictionary *)node;
@end

@interface SelectNodeTableViewController : UITableViewController
@property (strong, nonatomic) NSString* navtitle;
@property (strong, nonatomic) NSMutableArray* nodes;
@property (nonatomic, weak) id<SelectNodeTableDelegate> delegate;
@end
