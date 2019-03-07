//
//  TorrentCell.h
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TorrentCellIdentifier @"TorrentCellIdentifier"

@class ControlButton;

@interface TorrentCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *upperDetailLabel;
@property (nonatomic, retain) IBOutlet UILabel *lowerDetailLabel;
@property (nonatomic, retain) IBOutlet ControlButton *controlButton;

+ (id)cellFromNib;

- (void)useGreenColor;
- (void)useBlueColor;

@end
