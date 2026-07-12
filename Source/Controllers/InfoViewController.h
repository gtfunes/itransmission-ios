//
//  InfoViewController.h
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 iTransmission authors.
//  SPDX-License-Identifier: GPL-3.0-or-later
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface InfoViewController : UIViewController <WKNavigationDelegate>
{
    NSString *pageName;
    UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, retain) NSString *pageName;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

+ (id)infoWithPageName:(NSString*)pageName;
- (id)initWithPageName:(NSString*)pageName;

@end
