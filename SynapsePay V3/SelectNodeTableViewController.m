//
//  SelectNodeTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/26/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "SelectNodeTableViewController.h"

@interface SelectNodeTableViewController ()
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation SelectNodeTableViewController

-(NSMutableArray *)nodes{
    if (!_nodes) {
        _nodes = [[NSMutableArray alloc] init];
    }
    return _nodes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.navigationController.navigationBar setHidden:YES];
    [self.navBar.topItem setTitle:self.navtitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.nodes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSMutableDictionary* node = self.nodes[indexPath.row];
    
    [cell.textLabel setText:node[@"info"][@"nickname"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self dismissViewControllerAnimated:YES completion:^(void){
        if ([self.delegate respondsToSelector:@selector(selectedNode:)]) {
            [self.delegate selectedNode:[self.nodes[indexPath.row] mutableCopy]];
        }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
