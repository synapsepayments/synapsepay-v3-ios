//
//  AddIDViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/25/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "AddIDViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "JTProgressHUD.h"
#import "CommonFunctions.h"
#import "AppDelegate.h"

@interface AddIDViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
- (IBAction)launchCamera:(id)sender;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) AppDelegate* appDelegate;
@end

@implementation AddIDViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchCamera:(id)sender {
    UIImagePickerController *myPicker = [[UIImagePickerController alloc]init];
    myPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    myPicker.allowsEditing = YES;
    myPicker.delegate = self;
    // now we present the picker
    [self presentViewController:myPicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    NSData *imgData = UIImagePNGRepresentation(chosenImage);
    NSString* base64EncodedImage = [imgData base64EncodedStringWithOptions:0];
    
    [self submitDocWithData:base64EncodedImage];
}

- (void) submitDocWithData:(NSString *)attachment{
    [JTProgressHUD show];
    NSDictionary* payload = @{
                              @"login":@{
                                      @"oauth_key": [self.commonFunctionsInstance oauthKey]
                                      },
                              @"user":@{
                                      @"doc":@{
                                              @"attachment":[NSString stringWithFormat:@"data:text/png;base64,%@",attachment]
                                              },
                                      @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                      }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"user/doc/attachments/add"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [JTProgressHUD hide];
        self.appDelegate.userData = [responseObject[@"user"] mutableCopy];
        
        if (self.fromSettings) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

@end
