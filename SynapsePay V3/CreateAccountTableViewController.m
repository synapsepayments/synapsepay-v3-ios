//
//  CreateAccountTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/24/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "CreateAccountTableViewController.h"
#import "CNPPopupController.h"
#import "UIColor+FlatUI.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import "JTProgressHUD.h"
#import "CreateAccountTableViewController.h"
#import "AppDelegate.h"

@interface CreateAccountTableViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *mobileTextField;
@property (strong, nonatomic) IBOutlet UISwitch *legalSwitch;
@property (nonatomic, strong) CNPPopupController *popupController;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) AppDelegate* appDelegate;
@end

@implementation CreateAccountTableViewController

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
    [self.emailTextField setText:self.email];
    [self.mobileTextField setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showPopupWithStyle:CNPPopupStyleActionSheet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //open TOS
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://s3.amazonaws.com/synapse_django/tos/v3/SynapsePay_TOS.pdf"]];
        }else if (indexPath.row == 1){
            //open privacy
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://s3.amazonaws.com/synapse_django/tos/v3/SynapsePay_Privacy_Policy.pdf"]];
        }
    }else if (indexPath.section == 2 && indexPath.row == 0 && [self.legalSwitch isOn]){
        [self createUser];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *filter = @"(###) ### - ####";
    
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

- (void)showPopupWithStyle:(CNPPopupStyle)popupStyle{
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableParagraphStyle *paragraphStyle2 = NSMutableParagraphStyle.new;
    paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle2.lineSpacing = 6.f;
    paragraphStyle2.alignment = NSTextAlignmentLeft;
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thumbprint_icon-01"]];
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Important Information" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"To comply with federal Bank Secrecy Act and Anti-Money Laundering regulations, SynapsePay is required to verify your identity. In the next two steps, we will be asking for your address, DOB, last 4 of SSN & your photo ID." attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSParagraphStyleAttributeName : paragraphStyle2}];
    
    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"Tap in the dark area to get started." attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor pomegranateColor], NSParagraphStyleAttributeName : paragraphStyle}];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    UILabel *lineOneLabel = [[UILabel alloc] init];
    lineOneLabel.numberOfLines = 0;
    lineOneLabel.attributedText = lineOne;
    
    UILabel *lineTwoLabel = [[UILabel alloc] init];
    lineTwoLabel.numberOfLines = 0;
    lineTwoLabel.attributedText = lineTwo;
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[image,titleLabel, lineOneLabel, lineTwoLabel]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    [self.popupController presentPopupControllerAnimated:YES];
}

#pragma mark - CNPPopupController Delegate

- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    
}


- (void) createUser{
    [JTProgressHUD show];
    NSDictionary* payload = @{
                              @"client":@{
                                      @"client_id": [self.commonFunctionsInstance clientID],
                                      @"client_secret": [self.commonFunctionsInstance clientSecret]
                                      },
                              @"logins":@[@{
                                      @"email":self.emailTextField.text,
                                      @"password":self.passwordTextField.text,
                                      @"read_only":[NSNumber numberWithBool:NO]
                                      }],
                              @"phone_numbers":@[
                                      self.mobileTextField.text
                                      ],
                              @"legal_names":@[
                                      self.displayNameTextField.text
                                      ],
                              @"fingerprints":@[@{
                                                @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                                }]
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"user/create"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [JTProgressHUD hide];
        
        [self.commonFunctionsInstance setOauthKey:responseObject[@"oauth"][@"oauth_key"]];
        [self.commonFunctionsInstance setRefreshToken:responseObject[@"oauth"][@"refresh_token"]];
        [self.commonFunctionsInstance setOID:responseObject[@"user"][@"_id"][@"$oid"]];
        self.appDelegate.userData = [responseObject[@"user"] mutableCopy];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFlow" object:nil];
        [self performSegueWithIdentifier:@"showSSN" sender:self];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

@end
