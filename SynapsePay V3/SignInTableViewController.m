//
//  SignInTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/26/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "SignInTableViewController.h"
#import "SelectDeviceTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import "AppDelegate.h"
#import "JTProgressHUD.h"

@interface SignInTableViewController ()
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) NSMutableArray* phoneNumbers;
@end

@implementation SignInTableViewController

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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self signIn];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    SelectDeviceTableViewController *destViewController = segue.destinationViewController;
    destViewController.user = self.user;
    destViewController.email = self.email;
    destViewController.password = self.passwordTextField.text;
    destViewController.phoneNumbers = self.phoneNumbers;
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
                                      @"password":self.passwordTextField.text
                                      },
                              @"user":@{
                                      @"_id":@{
                                              @"$oid":self.user[@"_id"][@"$oid"]
                                              },
                                      @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                      }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"user/signin"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [JTProgressHUD hide];
        
        [self.commonFunctionsInstance setRefreshToken:responseObject[@"oauth"][@"refresh_token"]];
        [self.commonFunctionsInstance setOauthKey:responseObject[@"oauth"][@"oauth_key"]];
        [self.commonFunctionsInstance setOID:responseObject[@"user"][@"_id"][@"$oid"]];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFlow" object:nil];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.responseObject[@"phone_numbers"]) {
            [JTProgressHUD hide];
            self.phoneNumbers = [operation.responseObject[@"phone_numbers"] mutableCopy];
            [self performSegueWithIdentifier:@"showSelectDevice" sender:self];
        }else{
            [self.commonFunctionsInstance handleError:error withOperation:operation];
        }
    }];
}

@end
