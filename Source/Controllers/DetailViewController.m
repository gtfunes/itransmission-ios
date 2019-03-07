    //
//  DetailViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "Torrent.h"
#import "Controller.h"
#import "NSString+Additions.h"
#import "FlexibleLabelCell.h"
#import "NSDate+Helper.h"
#import "BandwidthController.h"
#import "FileListViewController.h"
#import "TrackersViewController.h"
#import "TrackerNode.h"
#import "PeersViewController.h"
#import "ALAlertBanner.h"

#define HEADER_SECTION 0
#define TITLE_ROW 0

#define STATE_SECTION 1
#define STATE_ROW 0
#define ERROR_MESSAGE_ROW (STATE_ROW+1)

#define SPEED_SECTION 2
#define DL_SPEED_ROW 0
#define UL_SPEED_ROW 1
#define AVERAGE_DL_SPEED_ROW 2
#define AVERAGE_UL_SPEED_ROW 3

#define GENERAL_INFO_SECTION 3
#define HASH_ROW 0
#define MAGNET_ROW 1
#define IS_PRIVATE_ROW 2
#define CREATOR_ROW 3
#define CREATED_ON_ROW 4
#define ACTIVITY_ROW 5
#define COMMENT_ROW 6

#define TRANSFER_SECTION 4
#define TOTAL_SIZE_ROW 0
#define SIZE_COMPLETED_ROW 1
#define PROGRESS_ROW 2
#define DOWNLOADED_ROW 3
#define UPLOADED_ROW 4
#define RATIO_ROW 5
#define SEEDERS_ROW 6
#define PEERS_ROW 7

#define ACTIONS_SECTION 5
#define RECHECK_DATA_ROW 0

#define MORE_SECTION 6
#define FILES_ROW 0
#define TRACKERS_ROW 1
#define PEERS_INFO_ROW 2

#define REMOVE_COMFIRM_TAG 1003

@implementation DetailViewController

@synthesize tableView = fTableView;
@synthesize torrent = fTorrent;
@synthesize startButton = fStartButton;
@synthesize pauseButton = fPauseButton;
@synthesize removeButton = fRemoveButton;
@synthesize refreshButton = fRefreshButton;
@synthesize bandwidthButton = fBandwidthButton;
@synthesize selectedIndexPath = fSelectedIndexPath;
@dynamic UIUpdateTimer;

- (id)initWithTorrent:(Torrent*)t controller:(Controller*)c {
    if ((self = [super initWithNibName:@"DetailViewController" bundle:nil])) {
        self.title = LocalizedString(@"Details");
        fTorrent = t;
        fController = c;

        self.startButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startButtonClicked:)];
		self.pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseButtonClicked:)];
		self.removeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeButtonClicked:)];
        
        self.bandwidthButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bandwidth-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(bandwidthButtonClicked:)];
        
		self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateUI)];

		UIBarButtonItem *flexSpaceOne = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *flexSpaceTwo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *flexSpaceThree = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *flexSpaceFour = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		self.toolbarItems = [NSArray arrayWithObjects:self.startButton, flexSpaceOne, self.pauseButton, flexSpaceTwo, self.refreshButton, flexSpaceThree, self.bandwidthButton, flexSpaceFour, self.removeButton, nil];

		displayedError = NO;
	}
    return self;
}

- (void)bandwidthButtonClicked:(id)sender
{
    BandwidthController *bandwidthController = [[BandwidthController alloc] initWithNibName:@"BandwidthController" bundle:nil];
    [bandwidthController setTorrent:self.torrent];
    [bandwidthController setController:self.controller];
    [self.navigationController pushViewController:bandwidthController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 7;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == MORE_SECTION) {
		return indexPath;
	}
    if (indexPath.section == ACTIONS_SECTION) {
        return indexPath;
    }
    if (indexPath.section == GENERAL_INFO_SECTION) {
        return indexPath;
    }
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == MORE_SECTION) {
        if (indexPath.row == FILES_ROW) {
            FileListViewController *c = [[FileListViewController alloc] initWithTorrent:self.torrent];
            [self.navigationController pushViewController:c animated:YES];
        } else if (indexPath.row == TRACKERS_ROW) {
            TrackersViewController *c = [[TrackersViewController alloc] initWithTorrent:self.torrent];
            [self.navigationController pushViewController:c animated:YES];
        } else if (indexPath.row == PEERS_INFO_ROW) {
            PeersViewController *c = [[PeersViewController alloc] initWithTorrent:self.torrent];
            [self.navigationController pushViewController:c animated:YES];
        }
	}
    else if (indexPath.section == ACTIONS_SECTION) {
        if (indexPath.row == RECHECK_DATA_ROW) {
            [fTorrent resetCache];
        }
    }
    else if (indexPath.section == GENERAL_INFO_SECTION) {
        if (indexPath.row == MAGNET_ROW) {
            [[UIPasteboard generalPasteboard] setString:[fTorrent magnetLink]];
            [fTorrentMagnetLinkLabel setText:LocalizedString(@"Copied!")];
        }
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[self.tableView setAllowsSelection:YES];

	[fTitleLabel setText:[fTorrent name]];
    
    [fTorrentMagnetLinkLabel setText:LocalizedString(@"Tap to Copy")];
    [fTorrentMagnetLinkLabel setTextAlignment:NSTextAlignmentRight];
    
    NSMutableArray *fPeers = [[NSMutableArray alloc] init];
    [fPeers removeAllObjects];
    [fPeers addObjectsFromArray:[fTorrent peers]];
    int totalSeeder = 0;
    int totalPeers = 0;
    for (NSDictionary *peer in fPeers) {
        BOOL isSeed = [[peer valueForKey:@"Seed"] boolValue];
        if (isSeed) {
            totalSeeder = totalSeeder + 1;
        } else {
            totalPeers = totalPeers + 1;
        }
    }
    totalSeeder = (int)totalSeeder + (int)[fTorrent webSeedCount];
    [fTorrentSeedersLabel setText:[NSString stringWithFormat:@"%d", totalSeeder]];
    [fTorrentPeersLabel setText:[NSString stringWithFormat:@"%d", totalPeers]];
    
    [fCreatedOnLabel setText:[NSDate stringForDisplayFromDate:[fTorrent dateCreated]]];
    
	if ([fTorrent icon])
		[fIconView setImage:[fTorrent icon]];
	else 
		[fIconView setImage:[UIImage imageNamed:@"question-mark.png"]];
    
	[fHashLabel setText:[fTorrent hashString]];

	[fIsPrivateSwitch setOn:[fTorrent privateTorrent]];
	[fCommentLabel setText:[fTorrent comment]];
	[fCommentCell resizeToFitText];
	[fCreatorLabel setText:[fTorrent creator]];
	
    int activityTimeInSeconds = (int)[fTorrent secondsDownloading] + (int)[fTorrent secondsSeeding];
    [fTorrentActivityLabel setText:[NSString stringForTime:activityTimeInSeconds]];
    [fTorrentActivityLabel setTextAlignment:NSTextAlignmentRight];
    
	fFilesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	fFilesCell.textLabel.text = LocalizedString(@"Files");
	fFilesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	fTrackersCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	fTrackersCell.textLabel.text = LocalizedString(@"Trackers");
	fTrackersCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    fPeersCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    fPeersCell.textLabel.text = LocalizedString(@"Peers");
    fPeersCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    fRecheckDataCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    fRecheckDataCell.textLabel.text = LocalizedString(@"Recheck Data");
    fRecheckDataCell.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:NO animated:animated];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:NotificationSessionStatusChanged object:self.controller];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationSessionStatusChanged object:self.controller];
}

- (void)startButtonClicked:(id)sender
{
	[fTorrent startTransfer];
	[self updateUI];
}

- (void)pauseButtonClicked:(id)sender
{
	[fTorrent stopTransfer];
	[self updateUI];
}

- (void)removeButtonClicked:(id)sender
{
	NSString *msg = LocalizedString(@"Are you sure to remove this torrent?");
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:msg delegate:self cancelButtonTitle:LocalizedString(@"Cancel") destructiveButtonTitle:LocalizedString(@"Yes and remove data") otherButtonTitles:LocalizedString(@"Yes but keep data"), nil];
	actionSheet.tag = REMOVE_COMFIRM_TAG;
	[actionSheet showFromToolbar:self.navigationController.toolbar];	
}

- (void)performRemove:(BOOL)trashData
{
    [self.UIUpdateTimer invalidate];
    
    [self.controller removeTorrents:[NSArray arrayWithObject:self.torrent] trashData:trashData afterDelay:1.50f];
    
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)sessionStatusChanged:(NSNotification*)notif
{
	[self updateUI];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
		case REMOVE_COMFIRM_TAG: {
			if (buttonIndex != actionSheet.cancelButtonIndex) {
				[self performRemove:(buttonIndex == [actionSheet destructiveButtonIndex])];
			}
		}
    }
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case HEADER_SECTION:
			return 1;
			break;
		case STATE_SECTION:
			return displayedError ? 2 : 1;
		case SPEED_SECTION:
			return 2;
			break;
		case GENERAL_INFO_SECTION:
			return 7;
			break;
		case TRANSFER_SECTION:
			return 8;
			break;
        case ACTIONS_SECTION:
            return 1;
            break;
		case MORE_SECTION:
			return 3;
			break;
		default:
            return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case HEADER_SECTION:
			switch (indexPath.row) {
				case TITLE_ROW:
					return fTitleCell;
					break;
				default:
					break;
			}
			break;
		case STATE_SECTION:
			switch (indexPath.row) {
				case STATE_ROW:
					return fStateCell;
					break;
				case ERROR_MESSAGE_ROW:
					return fErrorMessageCell;
					break;
				default:
					break;
			}
			break;
		case SPEED_SECTION:
			switch (indexPath.row) {
				case UL_SPEED_ROW:
					return fULSpeedCell;
					break;
				case DL_SPEED_ROW:
					return fDLSpeedCell;
					break;
                case AVERAGE_UL_SPEED_ROW:
                    return fAverageULSpeedCell;
                case AVERAGE_DL_SPEED_ROW:
                    return fAverageDLSpeedCell;
				default:
					break;
			}
			break;
		case GENERAL_INFO_SECTION:
			switch (indexPath.row) {
				case HASH_ROW:
					return fHashCell;
					break;
                case MAGNET_ROW:
                    return fTorrentMagnetLinkCell;
                    break;
				case CREATOR_ROW:
					return fCreatorCell;
					break;
				case CREATED_ON_ROW:
					return fCreatedOnCell;
					break;
                case ACTIVITY_ROW:
                    return fTorrentActivityCell;
                    break;
				case COMMENT_ROW:
					return fCommentCell;
					break;
				case IS_PRIVATE_ROW:
					return fIsPrivateCell;
					break;
				default:
					break;
			}
			break;
		case TRANSFER_SECTION:
			switch (indexPath.row) {
				case TOTAL_SIZE_ROW:
					return fTotalSizeCell;
					break;
				case SIZE_COMPLETED_ROW:
					return fCompletedSizeCell;
					break;
				case PROGRESS_ROW:
					return fProgressCell;
					break;
				case UPLOADED_ROW:
					return fUploadedSizeCell;
					break;
				case DOWNLOADED_ROW:
					return fDownloadedSizeCell;
					break;
				case RATIO_ROW:
					return fRatioCell;
					break;
                case SEEDERS_ROW:
                    return fTorrentSeedersCell;
                    break;
                case PEERS_ROW:
                    return fTorrentPeersCell;
                    break;
				default:
					break;
			}
			break;
        case ACTIONS_SECTION:
            switch (indexPath.row) {
                case RECHECK_DATA_ROW:
                    return fRecheckDataCell;
                    break;
                default:
                    break;
            }
            break;
		case MORE_SECTION:
			switch (indexPath.row) {
				case FILES_ROW:
					return fFilesCell;
					break;
                case TRACKERS_ROW:
                    return fTrackersCell;
                    break;
                case PEERS_INFO_ROW:
                    return fPeersCell;
                    break;
				default:
					break;
			}
			break;

		default:
			break;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	CGFloat height = cell.bounds.size.height;

	return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case TRANSFER_SECTION:
			return LocalizedString(@"Transfer");
			break;
        case ACTIONS_SECTION:
            return LocalizedString(@"Actions");
            break;
		case SPEED_SECTION:
			return LocalizedString(@"Speed");
			break;
		case GENERAL_INFO_SECTION:
			return LocalizedString(@"General Information");
			break;
		case MORE_SECTION:
			return LocalizedString(@"More");
			break;
		default:
			break;
	}
	return nil;
}

- (void)updateUI
{
    if (![self.controller torrentsCount]) {
        [self.navigationController popViewControllerAnimated:YES];

        return;
    } else {
        NSInteger count = [self.controller torrentsCount];
        BOOL found = NO;

        for (int i = 0; i < count; i++) {
            if ([[self.controller torrentAtIndex:i] isEqual:fTorrent]) {
                found = YES;

                break;
            }
        }

        if (!found) {
            [self.navigationController popViewControllerAnimated:YES];

            return;
        }
    }

	if ([self.controller isSessionActive]) {
		[self.startButton setEnabled:![fTorrent isActive]];
		[self.pauseButton setEnabled:[fTorrent isActive]];
	}
	else {
		[self.startButton setEnabled:NO];
		[self.pauseButton setEnabled:NO];
	}
	
	[fTorrent update];
	[fTotalSizeLabel setText:[NSString stringForFileSize:[fTorrent size]]];
	[fCompletedSizeLabel setText:[NSString stringForFileSize:[fTorrent haveVerified]]];
	[fProgressLabel setText:[NSString stringWithFormat:@"%.2f%%",[fTorrent progress] * 100.0f]];
	[fUploadedSizeLabel setText:[NSString stringForFileSize:[fTorrent uploadedTotal]]];
	[fDownloadedSizeLabel setText:[NSString stringForFileSize:[fTorrent downloadedTotal]]];

    NSMutableArray *fPeers = [[NSMutableArray alloc] init];
    [fPeers removeAllObjects];
    [fPeers addObjectsFromArray:[fTorrent peers]];
    int totalSeeder = 0;
    int totalPeers = 0;
    for (NSDictionary *peer in fPeers) {
        BOOL isSeed = [[peer valueForKey:@"Seed"] boolValue];
        if (isSeed) {
            totalSeeder = totalSeeder + 1;
        } else {
            totalPeers = totalPeers + 1;
        }
    }
    totalSeeder = (int)totalSeeder + (int)[fTorrent webSeedCount];

    [fTorrentSeedersLabel setText:[NSString stringWithFormat:@"%d", totalSeeder]];
    [fTorrentPeersLabel setText:[NSString stringWithFormat:@"%d", totalPeers]];
    
    int activityTimeInSeconds = (int)[fTorrent secondsDownloading] + (int)[fTorrent secondsSeeding];
    [fTorrentActivityLabel setText:[NSString stringForTime:activityTimeInSeconds]];
    [fTorrentActivityLabel setTextAlignment:NSTextAlignmentRight];

	BOOL hasError = [fTorrent isAnyErrorOrWarning];
	if (hasError) {
		if (!displayedError) {
            displayedError = YES;
            [fErrorMessageLabel setText:[fTorrent errorMessage]];
            [fErrorMessageCell resizeToFitText];
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:ERROR_MESSAGE_ROW inSection:STATE_SECTION]] withRowAnimation:UITableViewRowAnimationTop];
		}
	}
	else {
		if (displayedError) {
            displayedError = NO;
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:ERROR_MESSAGE_ROW inSection:STATE_SECTION]] withRowAnimation:UITableViewRowAnimationTop];
		}
	}
    
    if ([[fTorrent stateString] isEqualToString:LocalizedString(@"Downloading")])
        [fStartPauseButton setTitle:LocalizedString(@"Start") forState:UIControlStateNormal];
    else
        [fStartPauseButton setTitle:LocalizedString(@"Pause") forState:UIControlStateNormal];
	
	[fStateLabel setText:[fTorrent stateString]];
	[fRatioLabel setText:[NSString stringForRatio:[fTorrent ratio]]];
	
	[fULSpeedLabel setText:[NSString stringForSpeed:[fTorrent uploadRate]]];
	[fDLSpeedLabel setText:[NSString stringForSpeed:[fTorrent downloadRate]]];
}

@end
