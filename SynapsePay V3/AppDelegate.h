//
//  AppDelegate.h
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/7/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong,nonatomic) NSMutableArray *transactions;
@property (strong,nonatomic) NSMutableDictionary *userData;
@property (strong,nonatomic) NSMutableArray *nodes;
@property (strong,nonatomic) NSMutableArray *institutions;
@property (nonatomic) BOOL handlePIN;


@end
