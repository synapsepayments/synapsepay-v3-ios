//
//  TransactionsTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/21/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "TransactionsTableViewController.h"
#import "SearchUserTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "JTProgressHUD.h"
#import "CommonFunctions.h"
#import "UIColor+FlatUI.h"
#import "CNPPopupController.h"
#import "UINavigationBar+CustomNavBar.h"
#import <UIScrollView+InfiniteScroll.h>
#import "AppDelegate.h"
#import <DMPasscode/DMPasscode.h>

@interface TransactionsTableViewController ()<CNPPopupControllerDelegate>{
    int pageCurser;
}
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) CNPPopupController *popupController;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation TransactionsTableViewController

@synthesize refreshControl = _refreshControl;

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

-(UIRefreshControl *) refreshControl{
    if (!_refreshControl){
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshAccess) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAccess) name:@"reloadFlow" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTransView) name:@"reloadTransView" object:nil];
    
    [self.tableView addSubview:self.refreshControl];
    [self refreshAccess];
    [self getInstitutions];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // change indicator view style to white
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    
    // setup infinite scroll
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        //
        // fetch your data here, can be async operation,
        // just make sure to call finishInfiniteScroll in the end
        //
        
        // finish infinite scroll animation
        
        [weakSelf getTransactions:pageCurser isInitialState:NO];
        
        [tableView finishInfiniteScroll];
    }];
}

-(void)reloadTransView{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.appDelegate.transactions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    UIImageView* image = (UIImageView *)[cell viewWithTag:100];
    image.clipsToBounds = YES;
    image.layer.cornerRadius = 20;
    UILabel* title = (UILabel *)[cell viewWithTag:101];
    UILabel* body = (UILabel *)[cell viewWithTag:102];
    
    NSMutableDictionary* trans = self.appDelegate.transactions[indexPath.row];
    
    [title setText:[self getTitle:trans]];
    [title setTextColor:[self getTitleColor:trans]];
    [body setText:[self getBody:trans]];
    [image setImage:[self getImage:trans]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showPopupWithStyle:CNPPopupStyleActionSheet andTrans:self.appDelegate.transactions[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showSearchUser"]) {
        SearchUserTableViewController *destViewController = segue.destinationViewController;
        
        // Hide bottom tab bar in the detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}


- (void)showPopupWithStyle:(CNPPopupStyle)popupStyle andTrans:(NSMutableDictionary *)trans{
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[self getImage:trans]];
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[self getTitle:trans] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : [self getTitleColor:trans]}];
    
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:[self getBody:trans] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:[self getOtherText:trans] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11], NSForegroundColorAttributeName : [UIColor concreteColor], NSParagraphStyleAttributeName : paragraphStyle}];
    
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
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}

#pragma mark - CNPPopupController Delegate

- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {

}


- (BOOL) didReceive:(NSMutableDictionary *)trans{
    for (int i=0; i<[self.appDelegate.nodes count]; i++) {
        if ([self.appDelegate.nodes[i][@"_id"][@"$oid"] isEqualToString:trans[@"to"][@"id"][@"$oid"]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) didSend:(NSMutableDictionary *)trans{
    for (int i=0; i<[self.appDelegate.nodes count]; i++) {
        if ([self.appDelegate.nodes[i][@"_id"][@"$oid"] isEqualToString:trans[@"from"][@"id"][@"$oid"]]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getTitle:(NSMutableDictionary *)trans{
    NSString* title = [NSString stringWithFormat:@"%.2f %@",[trans[@"amount"][@"amount"] floatValue],trans[@"amount"][@"currency"]];;
    return title;
}

- (UIColor *)getTitleColor:(NSMutableDictionary *)trans{
    if ([self didReceive:trans]) {
        return [UIColor nephritisColor];
    }else{
        return [UIColor asbestosColor];
    }
}

- (NSString *)getBody:(NSMutableDictionary *)trans{
    NSString* body = @"";
    if ([self didReceive:trans]) {
        if ([self didSend:trans]) {
            //if you sent and received, then show the node nickname for better UX. Since the user is moving funds between their own accounts
            body = [NSString stringWithFormat:@"from %@ %@ node",trans[@"from"][@"nickname"],trans[@"from"][@"type"]];
        }else{
            body = [NSString stringWithFormat:@"from %@",[self.commonFunctionsInstance getLastObject:trans[@"from"][@"user"][@"legal_names"]]];
        }
    }else{
        body = [NSString stringWithFormat:@"to %@",[self.commonFunctionsInstance getLastObject:trans[@"to"][@"user"][@"legal_names"]]];
    }
    
    return body;
}

- (NSString *)getOtherText:(NSMutableDictionary *)trans{
    NSString* date = [self.commonFunctionsInstance getDateTime:trans[@"extra"][@"created_on"][@"$date"]];
    NSString* status = trans[@"recent_status"][@"status"];
    return [NSString stringWithFormat:@"%@ | %@ | %@",date,status,trans[@"_id"][@"$oid"]];
}

- (UIImage *)getImage:(NSMutableDictionary *)trans{
    UIImage* image = [[UIImage alloc] init];
    
    if ([self didReceive:trans]) {
        image  = [UIImage imageNamed:@"receive"];
    }else{
        image = [UIImage imageNamed:@"send"];
    }
    return image;
}

- (void) refreshAccess{
    [JTProgressHUD show];
    NSDictionary* payload = @{
            @"client": @{
                @"client_id": [self.commonFunctionsInstance clientID],
                @"client_secret": [self.commonFunctionsInstance clientSecret]
            },
            @"login":@{
                @"refresh_token": [self.commonFunctionsInstance refreshToken]
            },
            @"user":@{
                @"_id":@{
                        @"$oid":[self.commonFunctionsInstance oid]
                },
                @"fingerprint":[self.commonFunctionsInstance fingerprint]
            }
        };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"user/signin"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self getTransactions:1 isInitialState:YES];
        self.appDelegate.userData = [responseObject[@"user"] mutableCopy];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JTProgressHUD hide];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"landingView"];
        [self presentViewController:viewController animated:NO completion:nil];
    }];
    [self.refreshControl endRefreshing];
}

- (void) getTransactions:(int)page isInitialState:(BOOL)initial_state{
    
    NSDictionary* payload = @{
        @"login":@{
                @"oauth_key":[self.commonFunctionsInstance oauthKey]
        },
        @"user":@{
                @"fingerprint":[self.commonFunctionsInstance fingerprint]
        },
        @"filter":@{
            @"page":[NSNumber numberWithInt:page]
        }
    };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"trans/show"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (initial_state) {
            pageCurser = 2;
            self.appDelegate.transactions = [responseObject[@"trans"] mutableCopy];
            [self getNodes:1];
            [self openPinController];
            self.appDelegate.handlePIN = YES;
        }else{
            pageCurser = pageCurser+1;
            [self.appDelegate.transactions addObjectsFromArray:[responseObject[@"trans"] mutableCopy]];
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

- (void) getNodes:(int)page{
    
    NSDictionary* payload = @{
                              @"login":@{
                                      @"oauth_key":[self.commonFunctionsInstance oauthKey]
                                      },
                              @"user":@{
                                      @"fingerprint":[self.commonFunctionsInstance fingerprint]
                                      },
                              @"filter":@{
                                      @"page":[NSNumber numberWithInt:page]
                                      }
                              };
    
    [self.manager POST:[self.commonFunctionsInstance formURL:@"node/show"] parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [JTProgressHUD hide];
        self.appDelegate.nodes = [responseObject[@"nodes"] mutableCopy];
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadNodeView" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadSettingsView" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

- (void) getInstitutions{
    
    [self.manager GET:[self.commonFunctionsInstance formURL:@"institutions/show"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.appDelegate.institutions = [responseObject[@"banks"] mutableCopy];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.commonFunctionsInstance handleError:error withOperation:operation];
    }];
}

- (void) openPinController{
    if (![DMPasscode isPasscodeSet]) {
        return;
    }
    [DMPasscode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
        if (!success) {
            [self openPinController];
        }
    }];
}

@end
