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

    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Recreate the timer each time the view appears.
    // We intentionally do NOT schedule the timer in viewDidLoad because
    // NSTimer retains its target strongly, which would create a retain cycle
    // preventing the view controller from ever being deallocated.
    if (!self.UIUpdateTimer || ![self.UIUpdateTimer isValid]) {
        self.UIUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                             target:self
                                                           selector:@selector(updateUI)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // Invalidate the timer when the view disappears so the run loop releases
    // its strong reference to self, breaking the retain cycle.
    [self.UIUpdateTimer invalidate];
    self.UIUpdateTimer = nil;
}

- (void)dealloc
{
    // Safety net in case the view was never shown/disappeared normally.
    [self.UIUpdateTimer invalidate];
    self.UIUpdateTimer = nil;
}

@end
