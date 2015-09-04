//
//  SelectAccountTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/26/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "SelectAccountTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SignInTableViewController.h"

@interface SelectAccountTableViewController ()
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSMutableDictionary* user;
@end

@implementation SelectAccountTableViewController

-(CommonFunctions *) commonFunctionsInstance{
    if (!_commonFunctionsInstance) _commonFunctionsInstance = [[CommonFunctions alloc] init];
    return _commonFunctionsInstance;
}

-(AFHTTPRequestOperationManager *) manager{
    if (!_manager) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return _manager;
}

-(NSMutableArray *)users{
    if (!_users) {
        _users = [[NSMutableArray alloc] init];
    }
    return _users;
}

-(NSMutableDictionary *)user{
    if (!_user) {
        _user = [[NSMutableDictionary alloc] init];
    }
    return _user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    UIImageView* image = (UIImageView *)[cell viewWithTag:100];
    image.clipsToBounds = YES;
    image.layer.cornerRadius = 20;
    UILabel* title = (UILabel *)[cell viewWithTag:101];
    UILabel* body = (UILabel *)[cell viewWithTag:102];
    
    NSMutableDictionary* user = self.users[indexPath.row];
    
    [title setText:[self.commonFunctionsInstance getLastObject:user[@"legal_names"]]];
    [body setText:[NSString stringWithFormat:@"Created Via %@",user[@"client"][@"name"]]];
    
    if ([user[@"photos"] count] > 0) {
        [image sd_setImageWithURL:[NSURL URLWithString:[self.commonFunctionsInstance getLastObject:user[@"photos"]]] placeholderImage:nil completed:nil];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.user = [self.users[indexPath.row] mutableCopy];
    
    [self performSegueWithIdentifier:@"ShowSignin" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    SignInTableViewController *destViewController = segue.destinationViewController;
    destViewController.user = self.user;
    destViewController.email = self.email;
}

@end
