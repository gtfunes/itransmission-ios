//
//  StatisticsViewController.h
//  iTransmission
//
//  Created by Mike Chen on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Controller;

@interface StatisticsViewController : UIViewController {
    __weak Controller *fController;
    NSTimer *fUIUpdateTimer;
}

@property (nonatomic, retain) NSTimer *UIUpdateTimer;
@property (nonatomic, weak) Controller *controller;

- (void)updateUI;

@end
