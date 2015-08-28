//
//  NodesTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/22/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "NodesTableViewController.h"
#import "CommonFunctions.h"
#import "UIColor+FlatUI.h"
#import "CNPPopupController.h"
#import "AppDelegate.h"
#import "SelectBankTableViewController.h"

@interface NodesTableViewController ()<CNPPopupControllerDelegate>
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (nonatomic, strong) CNPPopupController *popupController;
@end

@implementation NodesTableViewController

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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNodeView) name:@"reloadNodeView" object:nil];
}

-(void) reloadNodeView{
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
    return [self.appDelegate.nodes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSMutableDictionary* node = self.appDelegate.nodes[indexPath.row];
    
    [cell.textLabel setText:node[@"info"][@"nickname"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showPopupWithStyle:CNPPopupStyleActionSheet andNode:self.appDelegate.nodes[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showAvailableBanks"]) {
        SelectBankTableViewController *destViewController = segue.destinationViewController;
        
        // Hide bottom tab bar in the detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

- (void)showPopupWithStyle:(CNPPopupStyle)popupStyle andNode:(NSMutableDictionary *)node{
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[self getImage:node]];
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[self getTitle:node] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:[self getBody:node] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:[self getOtherText:node] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11], NSForegroundColorAttributeName : [UIColor concreteColor], NSParagraphStyleAttributeName : paragraphStyle}];
    
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

- (UIImage *)getImage:(NSMutableDictionary *)node{
    UIImage* image = [[UIImage alloc] init];
    
    if ([node[@"type"] isEqualToString:@"SYNAPSE-US"]) {
        image  = [UIImage imageNamed:@"synapse_placeholder"];
    }else if([node[@"type"] isEqualToString:@"IOU"]){
        image = [UIImage imageNamed:@"iou_placeholder"];
    }else{
        image = [UIImage imageNamed:@"bank_placeholder"];
    }
    return image;
}

- (NSString *)getTitle:(NSMutableDictionary *)node{
    NSString* title = node[@"info"][@"nickname"];
    return title;
}

- (NSString *)getBody:(NSMutableDictionary *)node{
    NSString* body = @"";
    
    if ([node[@"type"] isEqualToString:@"SYNAPSE-US"] || [node[@"type"] isEqualToString:@"IOU"]) {
        body = [NSString stringWithFormat:@"%.2f %@",[node[@"info"][@"balance"][@"amount"] floatValue],node[@"info"][@"balance"][@"currency"]];
    }else{
        body = [NSString stringWithFormat:@"Account ***%@ | Routing ***%@",node[@"info"][@"account_num"],node[@"info"][@"routing_num"]];
    }
    
    return body;
}

- (NSString *)getOtherText:(NSMutableDictionary *)node{
    return [NSString stringWithFormat:@"%@ | %@ | %@",node[@"type"],node[@"allowed"],node[@"_id"][@"$oid"]];
}

@end
