//
//  SelectBankTableViewController.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/22/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "SelectBankTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "BankLoginTableViewController.h"

@interface SelectBankTableViewController ()
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic) NSMutableDictionary* selectedBank;
@end

@implementation SelectBankTableViewController

-(AppDelegate *) appDelegate{
    if (!_appDelegate) _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return _appDelegate;
}

-(NSMutableDictionary *) selectedBank{
    if (!_selectedBank) _selectedBank = [[NSMutableDictionary alloc] init];
    return _selectedBank;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    return [self.appDelegate.institutions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    // Configure the cell...
    UIImageView* image = (UIImageView *)[cell viewWithTag:100];
    image.clipsToBounds = YES;
    image.layer.cornerRadius = 20;
    UILabel* title = (UILabel *)[cell viewWithTag:101];
    
    NSMutableDictionary* bank = self.appDelegate.institutions[indexPath.row];
    
    [title setText:bank[@"bank_name"]];
    [image sd_setImageWithURL:[NSURL URLWithString:bank[@"logo"]] placeholderImage:[UIImage imageNamed:@"bank_placeholder"] completed:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedBank = self.appDelegate.institutions[indexPath.row];
    [self performSegueWithIdentifier:@"showBankLogin" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showBankLogin"]) {
        BankLoginTableViewController *destViewController = segue.destinationViewController;
        
        // Hide bottom tab bar in the detail view
        destViewController.selectedBank = self.selectedBank;
    }
}

@end
