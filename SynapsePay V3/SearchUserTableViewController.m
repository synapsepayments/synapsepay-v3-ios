//
//  SearchUserTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/26/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "SearchUserTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonFunctions.h"
#import "JTProgressHUD.h"
#import "LGSemiModalNavViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SelectNodeTableViewController.h"
#import "AppDelegate.h"
#import "CreateTransactionTableViewController.h"

@interface SearchUserTableViewController ()<UISearchBarDelegate,SelectNodeTableDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray* searchedUsers;
@property (strong, nonatomic) NSMutableDictionary* recivingUser;
@property (strong, nonatomic) NSMutableDictionary* selectedNode;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) SelectNodeTableViewController* selectNodeTableViewController;
@property (strong, nonatomic) LGSemiModalNavViewController *semiModal;
@property (strong, nonatomic) AppDelegate* appDelegate;
@end

@implementation SearchUserTableViewController

-(NSMutableArray *) searchedUsers{
    if (!_searchedUsers) {
        _searchedUsers = [[NSMutableArray alloc] init];
    }
    
    return _searchedUsers;
}

-(NSMutableDictionary *) selectedNode{
    if (!_selectedNode) {
        _selectedNode = [[NSMutableDictionary alloc] init];
    }
    
    return _selectedNode;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.searchBar setDelegate:self];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(UITextField*)findTextFieldInSubviewsRecursively:(UIView*)view
{
    if([view isKindOfClass:[UITextField class]]){
        return (UITextField*)view;
    }
    
    for (UIView *subView in view.subviews){
        UITextField* field = [self findTextFieldInSubviewsRecursively:subView];
        if(field != nil){
            return field;
        }
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.searchedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    UIImageView* image = (UIImageView *)[cell viewWithTag:100];
    image.clipsToBounds = YES;
    image.layer.cornerRadius = 20;
    UILabel* title = (UILabel *)[cell viewWithTag:101];
    UILabel* body = (UILabel *)[cell viewWithTag:102];
    
    NSMutableDictionary* user = self.searchedUsers[indexPath.row];
    
    [title setText:[self.commonFunctionsInstance getLastObject:user[@"legal_names"]]];
    [body setText:[NSString stringWithFormat:@"Created Via %@",user[@"client"][@"name"]]];
    
    if ([[NSString stringWithFormat:@"%@",user[@"photos"]] length] > 4) {
        [image sd_setImageWithURL:[NSURL URLWithString:user[@"photos"]] placeholderImage:nil completed:nil];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar resignFirstResponder];
    self.recivingUser = [self.searchedUsers[indexPath.row] mutableCopy];
    self.selectNodeTableViewController.navtitle = @"Send Funds From?";
    self.selectNodeTableViewController.nodes = [self.appDelegate.nodes mutableCopy];
    [self presentViewController:self.semiModal animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark- searchbar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length > 3){
        [self searchUser:searchText];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showTransSend"]) {
        CreateTransactionTableViewController *destViewController = segue.destinationViewController;
        destViewController.recivingUser = self.recivingUser;
        destViewController.selectedNode = self.selectedNode;
    }
}

- (void) searchUser:(NSString * )query{
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
                                      @"query":query
                                      }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"user/search"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.searchedUsers = [responseObject[@"users"] mutableCopy];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)selectedNode:(NSMutableDictionary *)node{
    self.selectedNode = node;
    [self performSegueWithIdentifier:@"showTransSend" sender:self];
}

@end
