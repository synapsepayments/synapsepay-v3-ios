//
//  EnterEmailTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/24/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "EnterEmailTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import "JTProgressHUD.h"
#import "CreateAccountTableViewController.h"
#import "SelectAccountTableViewController.h"

@interface EnterEmailTableViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong,nonatomic) NSMutableArray* users;
@end

@implementation EnterEmailTableViewController

-(AFHTTPRequestOperationManager *) manager{
    if (!_manager) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return _manager;
}

-(CommonFunctions *) commonFunctionsInstance{
    if (!_commonFunctionsInstance) _commonFunctionsInstance = [[CommonFunctions alloc] init];
    return _commonFunctionsInstance;
}

-(NSMutableArray *)users{
    if (!_users) {
        _users = [[NSMutableArray alloc]init];
    }
    return _users;
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
        [self searchUserWithEmail:self.emailTextField.text];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showSelectAccount"]) {
        SelectAccountTableViewController *destViewController = segue.destinationViewController;
        destViewController.users = self.users;
        destViewController.email = self.emailTextField.text;
    }else if ([segue.identifier isEqualToString:@"showCreate"]){
        CreateAccountTableViewController *destViewController = segue.destinationViewController;
        // Hide bottom tab bar in the detail view
        destViewController.email = self.emailTextField.text;

    }
}

- (void) searchUserWithEmail:(NSString * )email{
    [JTProgressHUD show];
    NSDictionary* payload = @{
                              @"client":@{
                                      @"client_id": [self.commonFunctionsInstance clientID],
                                      @"client_secret": [self.commonFunctionsInstance clientSecret]
                                      },
                              @"user":@{
                                      @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                      },
                              @"filter":@{
                                      @"page":[NSNumber numberWithInt:1],
                                      @"exact_match":[NSNumber numberWithBool:YES],
                                      @"query":email
                                      }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"user/search"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [JTProgressHUD hide];
        
        if ([responseObject[@"users"] count] == 0) {
            //do create account
            [self performSegueWithIdentifier:@"showCreate" sender:self];
        }else{
            self.users = [responseObject[@"users"] mutableCopy];
            [self performSegueWithIdentifier:@"showSelectAccount" sender:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

@end
