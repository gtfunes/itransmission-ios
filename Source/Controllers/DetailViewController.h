//
//  DetailViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatisticsViewController.h"

@class Torrent;
@class Controller;
@class FlexibleLabelCell;

@interface DetailViewController : StatisticsViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    __weak Torrent *fTorrent;
    
	UITableView *fTableView;
	UIBarButtonItem *fStartButton;
	UIBarButtonItem *fPauseButton;
	UIBarButtonItem *fRemoveButton;
	UIBarButtonItem *fRefreshButton;
    UIBarButtonItem *fBandwidthButton;
    NSIndexPath *fSelectedIndexPath;
	
	IBOutlet UITableViewCell *fTitleCell;
	IBOutlet UILabel *fTitleLabel;
	IBOutlet UIImageView *fIconView;
	
	IBOutlet UITableViewCell *fTotalSizeCell;
	IBOutlet UILabel *fTotalSizeLabel;
    
    IBOutlet UITableViewCell *fTorrentSeedersCell;
    IBOutlet UILabel *fTorrentSeedersLabel;
    
    IBOutlet UITableViewCell *fTorrentPeersCell;
    IBOutlet UILabel *fTorrentPeersLabel;
	
	IBOutlet UITableViewCell *fCompletedSizeCell;
	IBOutlet UILabel *fCompletedSizeLabel;
	
	IBOutlet UITableViewCell *fProgressCell;
	IBOutlet UILabel *fProgressLabel;
	
	IBOutlet UITableViewCell *fDownloadedSizeCell;
	IBOutlet UILabel *fDownloadedSizeLabel;
	
	IBOutlet UITableViewCell *fUploadedSizeCell;
	IBOutlet UILabel *fUploadedSizeLabel;
	
	IBOutlet UITableViewCell *fStateCell;
	IBOutlet UILabel *fStateLabel;
	
	IBOutlet FlexibleLabelCell *fErrorMessageCell;
	IBOutlet UILabel *fErrorMessageLabel;
	
	IBOutlet UITableViewCell *fHashCell;
	IBOutlet UILabel *fHashLabel;
	
	IBOutlet UITableViewCell *fRatioCell;
	IBOutlet UILabel *fRatioLabel;
	
    IBOutlet UITableViewCell *fRecheckDataCell;
    
    IBOutlet UIButton *fStartPauseButton;
	
    IBOutlet FlexibleLabelCell *fTorrentMagnetLinkCell;
    IBOutlet UILabel *fTorrentMagnetLinkLabel;
    
	IBOutlet UITableViewCell *fULSpeedCell;
	IBOutlet UILabel *fULSpeedLabel;
	
	IBOutlet UITableViewCell *fDLSpeedCell;
	IBOutlet UILabel *fDLSpeedLabel;
    
    IBOutlet UITableViewCell *fTorrentActivityCell;
	IBOutlet UILabel *fTorrentActivityLabel;
    
	IBOutlet UITableViewCell *fAverageULSpeedCell;
	IBOutlet UILabel *fAverageULSpeedLabel;
	
	IBOutlet UITableViewCell *fAverageDLSpeedCell;
	IBOutlet UILabel *fAverageDLSpeedLabel;
	
	IBOutlet UITableViewCell *fCreatorCell;
	IBOutlet UILabel *fCreatorLabel;
	
	IBOutlet UITableViewCell *fCreatedOnCell;
	IBOutlet UILabel *fCreatedOnLabel;
	
	IBOutlet FlexibleLabelCell *fCommentCell;
	IBOutlet UILabel *fCommentLabel;
	
	IBOutlet UITableViewCell *fIsPrivateCell;
	IBOutlet UISwitch *fIsPrivateSwitch;

    UITableViewCell *fPeersCell;
	UITableViewCell *fTrackersCell;
	UITableViewCell *fFilesCell;
	
	BOOL displayedError;
}

@property (nonatomic, retain) NSTimer *UIUpdateTimer;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, weak) Torrent *torrent;
@property (nonatomic, retain) UIBarButtonItem *startButton;
@property (nonatomic, retain) UIBarButtonItem *pauseButton;
@property (nonatomic, retain) UIBarButtonItem *removeButton;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;
@property (nonatomic, retain) UIBarButtonItem *bandwidthButton;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

- (id)initWithTorrent:(Torrent*)t controller:(Controller*)c;

- (void)startButtonClicked:(id)sender;
- (void)pauseButtonClicked:(id)sender;
- (void)removeButtonClicked:(id)sender;
- (void)sessionStatusChanged:(NSNotification*)notif;
- (void)bandwidthButtonClicked:(id)sender;

- (void)performRemove:(BOOL)trashData;

@end
