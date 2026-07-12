//
//  ControlButton.h
//  iTransmission
//
//  Created by Mike Chen on 10/5/10.
//  Copyright 2010 iTransmission authors.
//  SPDX-License-Identifier: GPL-3.0-or-later
//

#import <UIKit/UIKit.h>

@interface ControlButton : UIButton

@property (nonatomic, retain) UILabel *textLabel;

- (void)_initViews;
- (void)hesitateUpdate;

- (void)setResumeStyle;
- (void)setPauseStyle;

@end
