//
//  CreateTransactionTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/27/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "CreateTransactionTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import "JTProgressHUD.h"
#import "LGSemiModalNavViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SelectNodeTableViewController.h"
#import "AppDelegate.h"

@interface CreateTransactionTableViewController ()<SelectNodeTableDelegate>
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) SelectNodeTableViewController* selectNodeTableViewController;
@property (strong, nonatomic) LGSemiModalNavViewController *semiModal;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic) NSMutableDictionary* recivingNode;
@property (strong, nonatomic) IBOutlet UIImageView *recivingImageView;
@property (strong, nonatomic) IBOutlet UILabel *recivingNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *recivingClientTextField;
@property (strong, nonatomic) IBOutlet UILabel *recivingNodeLabel;
@property (strong, nonatomic) IBOutlet UILabel *sendingNodeLabel;
@property (strong, nonatomic) IBOutlet UITextField *amountTextField;
@end

@implementation CreateTransactionTableViewController

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

-(SelectNodeTableViewController *)selectNodeTableViewController{
    if (!_selectNodeTableViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _selectNodeTableViewController = (SelectNodeTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"selectNodesView"];
        _selectNodeTableViewController.delegate = self;
    }
    return _selectNodeTableViewController;
}

-(LGSemiModalNavViewController *)semiModal{
    if (!_semiModal) {
        _semiModal = [[LGSemiModalNavViewController alloc]initWithRootViewController:self.selectNodeTableViewController];
        
        //Selected customization properties, see more in the header of the LGSemiModalNavViewController
        _semiModal.backgroundShadeColor = [UIColor blackColor];
        _semiModal.animationSpeed = 0.2f;
        _semiModal.tapDismissEnabled = YES;
        _semiModal.backgroundShadeAlpha = 0.4;
        _semiModal.scaleTransform = CGAffineTransformMakeScale(.94, .94);
    }
    //Make sure to set a height on the view controller here.
    _semiModal.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
    
    return _semiModal;
}

-(NSMutableDictionary *)recivingUser{
    if (!_recivingUser) {
        _recivingUser = [[NSMutableDictionary alloc] init];
    }
    return _recivingUser;
}

-(NSMutableDictionary *)recivingNode{
    if (!_recivingNode) {
        _recivingNode = [[NSMutableDictionary alloc] init];
        self.recivingNode = [[self.recivingUser[@"nodes"] lastObject] mutableCopy];
        for (int i=0; i<[self.recivingUser[@"nodes"] count]; i++) {
            if ([self.recivingUser[@"nodes"][i][@"type"] isEqualToString:@"SYNAPSE-US"]) {
                self.recivingNode = [self.recivingUser[@"nodes"][i] mutableCopy];
            }
        }
    }
    return _recivingNode;
}

-(NSMutableDictionary *) selectedNode{
    if (!_selectedNode) {
        _selectedNode = [[NSMutableDictionary alloc] init];
    }
    
    return _selectedNode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recivingImageView.clipsToBounds = YES;
    self.recivingImageView.layer.cornerRadius = 20;
    [self reloadData];
}

-(void) reloadData{
    if ([self.recivingUser[@"photos"] count] > 0) {
        [self.recivingImageView sd_setImageWithURL:[NSURL URLWithString:[self.commonFunctionsInstance getLastObject:self.recivingUser[@"photos"]]] placeholderImage:nil completed:nil];
    }
    
    [self.recivingNameTextField setText:[self.commonFunctionsInstance getLastObject:self.recivingUser[@"legal_names"]]];
    [self.recivingClientTextField setText:[NSString stringWithFormat:@"Created Via %@",self.recivingUser[@"client"][@"name"]]];
    [self.recivingNodeLabel setText:self.recivingNode[@"info"][@"nickname"]];
    [self.sendingNodeLabel setText:self.selectedNode[@"info"][@"nickname"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1 && indexPath.section == 0) {
        self.selectNodeTableViewController.navtitle = @"Send Funds To?";
        self.selectNodeTableViewController.nodes = [self.recivingUser[@"nodes"] mutableCopy];
        [self presentViewController:self.semiModal animated:YES completion:nil];
    }
    else if(indexPath.row == 0 && indexPath.section == 2){
        [self createTransaction];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)selectedNode:(NSMutableDictionary *)node{
    self.recivingNode = node;
    [self reloadData];
}

-(void) createTransaction{
    [JTProgressHUD show];
    NSDictionary* payload = @{
                              @"login":@{
                                      @"oauth_key":[self.commonFunctionsInstance oauthKey]
                                      },
                              @"user":@{
                                      @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                      },
                              @"trans":@{
                                      @"from":@{
                                              @"type":self.selectedNode[@"type"],
                                              @"id":self.selectedNode[@"_id"][@"$oid"]
                                              },
                                      @"to":@{
                                              @"type":self.recivingNode[@"type"],
                                              @"id":self.recivingNode[@"_id"][@"$oid"]
                                              },
                                      @"amount":@{
                                              @"amount":self.amountTextField.text,
                                              @"currency":@"USD"
                                              },
                                      @"extra":@{
                                              
                                              }
                                      }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"trans/add"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [JTProgressHUD hide];
        [self.appDelegate.transactions insertObject:[responseObject[@"trans"] mutableCopy] atIndex:0];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTransView" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

@end
