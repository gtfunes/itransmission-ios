//
//  StatisticsViewController.m
//  iTransmission
//
//  Created by Mike Chen on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatisticsViewController.h"

@implementation StatisticsViewController
@synthesize controller = fController;
@synthesize UIUpdateTimer = fUIUpdateTimer;

#pragma mark - View lifecycle

- (void)updateUI
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.UIUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [self updateUI];
}

- (void)dealloc
{
    [self.UIUpdateTimer invalidate];
}

@end
