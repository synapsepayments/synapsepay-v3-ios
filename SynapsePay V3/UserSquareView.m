//
//  UserSquareView.m
//  Synapse-Buyer
//
//  Created by Sankaet Pathak on 1/12/14.
//  Copyright (c) 2014 Worksquid. All rights reserved.
//

@import QuartzCore;
#import "UIColor+FlatUI.h"
#import "UserSquareView.h"

@implementation UserSquareView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"UserSquareView" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UIView class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        self.frame = frame;
        self.bgLabel.bounds = CGRectMake(self.bgLabel.bounds.origin.x, self.bgLabel.bounds.origin.y, frame.size.width, self.bgLabel.bounds.size.height);
        
        [self.avatarImageView setClipsToBounds:YES];
        
        [self.bgLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgLabel setAlpha:0.7f];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bgLabel.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
        [self.bgLabel.layer insertSublayer:gradient atIndex:0];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
