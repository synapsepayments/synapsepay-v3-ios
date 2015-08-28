//
//  UINavigationBar+CustomNavBar.m
//  SynapsePay V3
//
//  Created by Sankaet Pathak on 8/22/15.
//  Copyright (c) 2015 Synapse Payments. All rights reserved.
//

#import "UINavigationBar+CustomNavBar.h"
#import "UIColor+FlatUI.h"

@implementation UINavigationBar (CustomNavBar)

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGSize amendedSize = [super sizeThatFits:size];
    
    amendedSize.height = 60.f;
    
    amendedSize.width = screenRect.size.width;
    
//    self.barTintColor = [UIColor synapseColor];
//    self.tintColor = [UIColor whiteColor];
//    [self
//     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//    self.translucent = NO;
//    self.barStyle = UIBarStyleBlack;
//    
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"teal-circuits"]
//                                       forBarMetrics:UIBarMetricsDefault];
//    
//    
//    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                               [UIColor whiteColor],
//                                               NSForegroundColorAttributeName,
//                                               [UIFont boldSystemFontOfSize:20],
//                                               NSFontAttributeName,
//                                               nil];
//
//    
//    [self setTitleTextAttributes:navbarTitleTextAttributes];
    
    return amendedSize;
}

@end
