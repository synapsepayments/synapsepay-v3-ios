//
//  BankMFATableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/23/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "BankMFATableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import "JTProgressHUD.h"
#import "BankMFATableViewController.h"
#import "AppDelegate.h"

@interface BankMFATableViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *bankLogo;
@property (strong, nonatomic) IBOutlet UITextField *mfaTextField;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@end

@implementation BankMFATableViewController

-(NSMutableDictionary *) selectedBank{
    if (!_selectedBank) _selectedBank = [[NSMutableDictionary alloc] init];
    return _selectedBank;
}

-(NSMutableDictionary *) nodeInfo{
    if (!_nodeInfo) _nodeInfo = [[NSMutableDictionary alloc] init];
    return _nodeInfo;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.bankLogo sd_setImageWithURL:[NSURL URLWithString:self.selectedBank[@"logo"]] placeholderImage:[UIImage imageNamed:@"bank_placeholder"] completed:nil];
    [self setTitle:self.selectedBank[@"bank_name"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return self.nodeInfo[@"extra"][@"mfa"][@"message"];
    }return @" ";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self doBankMFAWithID:self.nodeInfo[@"_id"][@"$oid"] andAnswer:self.mfaTextField.text];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) doBankMFAWithID:(NSString *)node_id andAnswer:(NSString *)answer{
    [JTProgressHUD show];
    NSDictionary* payload = @{
                                @"login":@{
                                    @"oauth_key": [self.commonFunctionsInstance oauthKey]
                                    },
                                @"user":@{
                                        @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                },
                                @"node":@{
                                        @"_id":@{
                                                @"$oid":node_id
                                                },
                                        @"verify":@{
                                                @"mfa":answer,
                                                }
                                }
                            };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"node/verify"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [JTProgressHUD hide];
        
        if (responseObject[@"nodes"][0][@"extra"][@"mfa"]) {
            self.nodeInfo = responseObject[@"nodes"][0];
            [self.tableView reloadData];
            [self.mfaTextField setText:@""];
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
