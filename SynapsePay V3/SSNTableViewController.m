//
//  SSNTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/25/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "SSNTableViewController.h"
#import "SCLAlertView.h"
#import "UIColor+FlatUI.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import "JTProgressHUD.h"
#import "CreateAccountTableViewController.h"
#import "AppDelegate.h"

@interface SSNTableViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *DOBTextField;
@property (strong, nonatomic) IBOutlet UITextField *ssnTextField;
@property (strong, nonatomic) IBOutlet UITextField *streetAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *zipTextField;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) AppDelegate* appDelegate;
@end

@implementation SSNTableViewController

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

-(AppDelegate *) appDelegate{
    if (!_appDelegate) _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return _appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.DOBTextField setDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *filter = @"##/##/####";
    
    if(!filter) return YES; // No filter provided, allow anything
    
    NSString *changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(range.length == 1 && // Only do for single deletes
       string.length < range.length &&
       [[textField.text substringWithRange:range] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound)
    {
        // Something was deleted.  Delete past the previous number
        NSInteger location = changedString.length-1;
        if(location > 0)
        {
            for(; location > 0; location--)
            {
                if(isdigit([changedString characterAtIndex:location]))
                {
                    break;
                }
            }
            changedString = [changedString substringToIndex:location];
        }
    }
    
    textField.text = [self.commonFunctionsInstance filteredStringFromString:changedString WithFilter:filter];
    
    return NO;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //submit SSN
            [self submitSSN];
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showID" sender:self];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) submitSSN{
    NSArray *dob = [self.DOBTextField.text componentsSeparatedByString:@"/"];
    NSArray* names = [self.fullNameTextField.text componentsSeparatedByString:@" "];
    if ([names count] < 2) {
        return;
    }
    [JTProgressHUD show];
    NSDictionary* payload = @{
                              @"login":@{
                                      @"oauth_key": [self.commonFunctionsInstance oauthKey]
                                      },
                              @"user":@{
                                      @"doc":@{
                                              @"birth_day":dob[1],
                                              @"birth_month":dob[0],
                                              @"birth_year":dob[2],
                                              @"name_first":names[0],
                                              @"name_last":names[1],
                                              @"address_street1":self.streetAddressTextField.text,
                                              @"address_postal_code":self.zipTextField.text,
                                              @"address_country_code":@"US",
                                              @"document_value":self.ssnTextField.text,
                                              @"document_type":@"SSN"
                                              },
                                      @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                      }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"user/doc/add"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [JTProgressHUD hide];
        self.appDelegate.userData = [responseObject[@"user"] mutableCopy];
        if (self.fromSettings) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self performSegueWithIdentifier:@"showID" sender:self];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

@end
