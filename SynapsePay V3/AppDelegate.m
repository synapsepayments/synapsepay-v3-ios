//
//  AppDelegate.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/7/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+FlatUI.h"
#import "Helpshift.h"
#import <DMPasscode/DMPasscode.h>
#import "CommonFunctions.h"

@interface AppDelegate ()
@property (strong, nonatomic) CommonFunctions* commonFunctionsInstance;
@end


@implementation AppDelegate

-(CommonFunctions *) commonFunctionsInstance{
    if (!_commonFunctionsInstance) _commonFunctionsInstance = [[CommonFunctions alloc] init];
    return _commonFunctionsInstance;
}

- (NSMutableDictionary *) userData{
    if (!_userData) _userData = [[NSMutableDictionary alloc] init];
    return _userData;
}

- (NSMutableArray *) nodes{
    if (!_nodes) _nodes = [[NSMutableArray alloc] init];
    return _nodes;
}

- (NSMutableArray *) transactions{
    if (!_transactions) _transactions = [[NSMutableArray alloc] init];
    return _transactions;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Helpshift installForApiKey:[self.commonFunctionsInstance getConfigDict][@"HELPSHIFT_API_KEY"] domainName:[self.commonFunctionsInstance getConfigDict][@"HELPSHIFT_DOMAIN_NAME"] appID:[self.commonFunctionsInstance getConfigDict][@"HELPSHIFT_APP_ID"]];
    
    if (launchOptions != nil) //Handle PushNotification when app is opened
    {
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil &&
            [[userInfo objectForKey:@"origin"] isEqualToString:@"helpshift"])
        {
            [[Helpshift sharedInstance] handleRemoteNotification:userInfo
                                                  withController:self.window.rootViewController];
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (self.handlePIN) {
        [self openPinController];
    }
}

- (void) openPinController{
    if (![DMPasscode isPasscodeSet]) {
        return;
    }
    [DMPasscode showPasscodeInViewController:self.window.rootViewController completion:^(BOOL success, NSError *error) {
        if (!success) {
            [self openPinController];
        }
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"landingView"];
//    [self.window.rootViewController presentViewController:viewController animated:NO completion:nil];
    self.window.tintColor = [UIColor synapseColor];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.synapsepay.SynapsePay_V3" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SynapsePay_V3" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SynapsePay_V3.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
