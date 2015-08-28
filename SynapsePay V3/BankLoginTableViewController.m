//
//  BankLoginTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/23/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "BankLoginTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import "JTProgressHUD.h"
#import "BankMFATableViewController.h"
#import "AppDelegate.h"

@interface BankLoginTableViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *bankLogo;
@property (strong, nonatomic) IBOutlet UITextField *userIdTextField;
@property (strong, nonatomic) IBOutlet UITextField *userPwTextField;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) NSMutableDictionary* nodeInfo;
@end

@implementation BankLoginTableViewController

-(NSMutableDictionary *) selectedBank{
    if (!_selectedBank) _selectedBank = [[NSMutableDictionary alloc] init];
    return _selectedBank;
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

-(CommonFunctions *) commonFunctionsInstance{
    if (!_commonFunctionsInstance) _commonFunctionsInstance = [[CommonFunctions alloc] init];
    return _commonFunctionsInstance;
}

-(NSMutableDictionary *) nodeInfo{
    if (!_nodeInfo) _nodeInfo = [[NSMutableDictionary alloc] init];
    return _nodeInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.bankLogo sd_setImageWithURL:[NSURL URLWithString:self.selectedBank[@"logo"]] placeholderImage:[UIImage imageNamed:@"bank_placeholder"] completed:nil];
    [self setTitle:self.selectedBank[@"bank_name"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self doBankLoginWithBankID:self.userIdTextField.text andPassword:self.userPwTextField.text];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showBankMFA"]) {
        BankMFATableViewController *destViewController = segue.destinationViewController;
        
        // Hide bottom tab bar in the detail view
        destViewController.selectedBank = self.selectedBank;
        destViewController.nodeInfo = self.nodeInfo;
    }
}

- (void) doBankLoginWithBankID:(NSString * )bank_id andPassword:(NSString *)bank_pw{
    [JTProgressHUD show];
    NSDictionary* payload = @{
                              @"login":@{
                                      @"oauth_key": [self.commonFunctionsInstance oauthKey]
                                      },
                              @"user":@{
                                      @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                      },
                              @"node":@{
                                      @"type":@"ACH-US",
                                      @"info":@{
                                          @"bank_id":bank_id,
                                          @"bank_pw":bank_pw,
                                          @"bank_name":self.selectedBank[@"bank_code"]
                                      }
                                  }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"node/add"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [JTProgressHUD hide];
        
        if (responseObject[@"nodes"][0][@"extra"][@"mfa"]) {
            self.nodeInfo = responseObject[@"nodes"][0];
            [self performSegueWithIdentifier:@"showBankMFA" sender:self];
        }else{
            for (int i=0; i<[responseObject[@"nodes"] count]; i++) {
                [self.appDelegate.nodes addObject:[responseObject[@"nodes"][i] mutableCopy]];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadNodeView" object:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

@end
