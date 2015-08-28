//
//  SelectDeviceTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/26/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "SelectDeviceTableViewController.h"
#import "EnterPINTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import "AppDelegate.h"
#import "JTProgressHUD.h"

@interface SelectDeviceTableViewController ()
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic) NSString* phoneNumber;
@end

@implementation SelectDeviceTableViewController

-(NSMutableDictionary *)user{
    if (!_user) {
        _user = [[NSMutableDictionary alloc] init];
    }
    return _user;
}


-(NSMutableArray *)phoneNumbers{
    if (!_phoneNumbers) {
        _phoneNumbers = [[NSMutableArray alloc] init];
    }
    return _phoneNumbers;
}

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

-(AppDelegate *) appDelegate{
    if (!_appDelegate) _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return _appDelegate;
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
    return [self.phoneNumbers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString* phoneNumber = self.phoneNumbers[indexPath.row];
    
    [cell.textLabel setText:phoneNumber];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.phoneNumber = self.phoneNumbers[indexPath.row];
    [self signIn];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    EnterPINTableViewController *destViewController = segue.destinationViewController;
    destViewController.user = self.user;
    destViewController.email = self.email;
    destViewController.password = self.password;
    destViewController.phoneNumber = self.phoneNumber;
}


- (void) signIn{
    [JTProgressHUD show];
    NSDictionary* payload = @{
                              @"client": @{
                                      @"client_id": [self.commonFunctionsInstance clientID],
                                      @"client_secret": [self.commonFunctionsInstance clientSecret]
                                      },
                              @"login":@{
                                      @"email": self.email,
                                      @"password":self.password
                                      },
                              @"user":@{
                                      @"_id":@{
                                              @"$oid":self.user[@"_id"][@"$oid"]
                                              },
                                      @"fingerprint":[self.commonFunctionsInstance fingerprint],
                                      @"phone_number":self.phoneNumber,
                                      }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"user/signin"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [JTProgressHUD hide];
        
        [self performSegueWithIdentifier:@"showEnterPIN" sender:self];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

@end
