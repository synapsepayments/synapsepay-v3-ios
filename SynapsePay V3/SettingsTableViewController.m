//
//  SettingsTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/23/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SSNTableViewController.h"
#import "AddIDViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserSquareView.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"
#import "Helpshift.h"
#import "JTProgressHUD.h"
#import <DMPasscode/DMPasscode.h>

@interface SettingsTableViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) UserSquareView* squareView;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@end

@implementation SettingsTableViewController


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

-(UserSquareView *)squareView{
    if (!_squareView) {
        _squareView = [[UserSquareView alloc]initWithFrame:CGRectMake(0,-self.tableView.frame.size.width,self.tableView.frame.size.width,self.tableView.frame.size.width)];
    }
    [self reloadSquareView];
    return _squareView;
}

-(void) reloadSquareView{
    [_squareView.fullNameLabel setText:[self.commonFunctionsInstance getLastObject:self.appDelegate.userData[@"legal_names"]]];
    
    if ([self.appDelegate.userData[@"photos"] count] > 0) {
        [_squareView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[self.commonFunctionsInstance getLastObject:self.appDelegate.userData[@"photos"]]] placeholderImage:nil completed:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSettingsView) name:@"reloadSettingsView" object:nil];
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.frame.size.width, 0, 0, 0);
    [self.tableView addSubview:self.squareView];
    [self.tableView setShowsVerticalScrollIndicator:NO];
}

-(void) reloadSettingsView{
    [self reloadSquareView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < 0) {
        CGRect f = self.squareView.frame;
        f.origin.y = yOffset;
        f.size.height =  -yOffset;
        self.squareView.frame = f;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showSSN"]) {
        SSNTableViewController *destViewController = segue.destinationViewController;
        
        // Hide bottom tab bar in the detail view
        destViewController.fromSettings = YES;
        destViewController.hidesBottomBarWhenPushed = YES;
    }else if ([segue.identifier isEqualToString:@"showID"]){
        AddIDViewController *destViewController = segue.destinationViewController;
        
        // Hide bottom tab bar in the detail view
        destViewController.fromSettings = YES;
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIImagePickerController *myPicker = [[UIImagePickerController alloc]init];
            myPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            myPicker.allowsEditing = YES;
            myPicker.delegate = self;
            // now we present the picker
            [self presentViewController:myPicker animated:YES completion:nil];
        }else if (indexPath.row == 1) {
            [DMPasscode setupPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
            }];
        }
    }else if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"showSSN" sender:self];
        }else if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showID" sender:self];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [[Helpshift sharedInstance] showFAQs:self withOptions:@{@"gotoConversationAfterContactUs":@"NO"}];
        }else if (indexPath.row == 1) {
            [[Helpshift sharedInstance] showConversation:self withOptions:@{@"gotoConversationAfterContactUs":@"YES"}];
        }else if (indexPath.row == 2){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://synapsepay.com/legal/"]];
        }
    }
    else if (indexPath.section == 3){
        if (indexPath.row == 0) {
            [self.commonFunctionsInstance signout];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"landingView"];
            [self presentViewController:viewController animated:NO completion:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    NSData *imgData = UIImagePNGRepresentation(chosenImage);
    NSString* base64EncodedImage = [imgData base64EncodedStringWithOptions:0];
    
    [self submitAvatarWithData:base64EncodedImage];
}

- (void) submitAvatarWithData:(NSString *)attachment{
    [JTProgressHUD show];
    NSDictionary* payload = @{
                              @"login":@{
                                      @"oauth_key": [self.commonFunctionsInstance oauthKey]
                                      },
                              @"user":@{
                                      @"doc":@{
                                              @"attachment":[NSString stringWithFormat:@"data:text/png;base64,%@",attachment],
                                              @"public":[NSNumber numberWithBool:YES]
                                              },
                                      @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                      }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"user/doc/attachments/add"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [JTProgressHUD hide];
        self.appDelegate.userData = [responseObject[@"user"] mutableCopy];
        [self reloadSquareView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

@end
