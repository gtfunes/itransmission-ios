//
//  TorrentViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "TorrentViewController.h"
#import "Controller.h"
#import "TorrentCell.h"
#import "Torrent.h"
#import "ALAlertBanner.h"
#import "SVWebViewController.h"
#import "PrefViewController.h"
// UIAlertViewPrivate.h removed — UIAlertController provides text fields natively
#import "TDBadgedCell.h"
#import "NSString+Additions.h"
#import "DetailViewController.h"
#import "ControlButton.h"
#import "BandwidthController.h"
#import "InfoViewController.h"

// ADD_TAG, ADD_FROM_URL_TAG, ADD_FROM_MAGNET_TAG, REMOVE_COMFIRM_TAG removed —
// UIAlertController uses inline action blocks instead of delegate tags.

@implementation TorrentViewController

- (void)dealloc
{
    // Remove all NSNotificationCenter observers registered in viewDidLoad.
    // Without this, if this view controller is ever deallocated the notification
    // center would fire into freed memory causing an EXC_BAD_ACCESS crash.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@synthesize tableView;
@synthesize activityIndicator;
@synthesize activityItemView;
@synthesize activityCounterBadge;
@synthesize normalToolbarItems;
@synthesize editToolbarItems;
@synthesize doneButton;
@synthesize infoButton;
@synthesize selectedIndexPaths;
@synthesize activityItem;
@synthesize pref;
@dynamic UIUpdateTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)];
        UIBarButtonItem *flexSpaceOne = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateUI)];
		UIBarButtonItem *flexSpaceTwo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *prefButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(prefButtonClicked:)];
		UIBarButtonItem *flexSpaceThree = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *bandwidthButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bandwidth-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(bandwidthButtonClicked:)];
		
        self.normalToolbarItems = [NSArray arrayWithObjects:addButton, flexSpaceOne, refreshButton, flexSpaceTwo, bandwidthButton, flexSpaceThree, prefButton, nil];
        self.toolbarItems = self.normalToolbarItems;
        
		UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(resumeButtonClicked:)];
		UIBarButtonItem *resumeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseButtonClicked:)];
		UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeButtonClicked:)];
		UIBarButtonItem *_flexSpaceOne = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *_flexSpaceTwo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		self.editToolbarItems = [NSArray arrayWithObjects:resumeButton, _flexSpaceOne, pauseButton, _flexSpaceTwo, removeButton, nil];
        
		self.title = LocalizedString(@"Transfers");
    }

    return self;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.controller torrentsCount];
    }

    return 0;
}

- (void)tableView:(UITableView *)ftableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.tableView.editing == NO) {
		DetailViewController *detailController = [[DetailViewController alloc] initWithTorrent:[self.controller torrentAtIndex:indexPath.row] controller:self.controller];
		[self.navigationController pushViewController:detailController animated:YES];
		[ftableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		if ([self.selectedIndexPaths count] == 0) {
			for (UIBarButtonItem *item in self.editToolbarItems) {
				[item setEnabled:YES];
			}
		}
		[self.selectedIndexPaths addObject:indexPath];
		TorrentCell *cell = (TorrentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.controlButton setEnabled:NO];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.tableView.editing) {
		[self.selectedIndexPaths removeObject:indexPath];

		if ([self.selectedIndexPaths count] == 0) {
			for (UIBarButtonItem *item in self.editToolbarItems) {
				[item setEnabled:NO];
			}
		}

		TorrentCell *cell = (TorrentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.controlButton setEnabled:YES];
	}
}

- (UITableViewCell *)tableView:(UITableView *)ftableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    TorrentCell *cell = (TorrentCell*)[ftableView dequeueReusableCellWithIdentifier:TorrentCellIdentifier];
    
    if (!cell) {
        cell = [TorrentCell cellFromNib];
		[cell.controlButton addTarget:self action:@selector(controlButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
    
    Torrent *t = [self.controller torrentAtIndex:index];
    [self setupCell:cell forTorrent:t];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f; 
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath { 
	return UITableViewCellEditingStyleDelete;
}
       
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
    self.selectedIndexPaths = [NSMutableArray arrayWithObject:indexPath];
    NSString *msg = [NSString stringWithFormat:LocalizedString(@"Are you sure to remove %@ torrent?"), [torrent name]];

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:msg
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];

    __weak __typeof(self) weakSelf = self;
    [actionSheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Yes and remove data")
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction *action) {
        [weakSelf performRemoveSelected:YES];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Yes but keep data")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
        [weakSelf performRemoveSelected:NO];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Cancel")
                                                    style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction *action) {
        weakSelf.selectedIndexPaths = [NSMutableArray array];
    }]];

    actionSheet.popoverPresentationController.sourceView = self.view;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)addButtonClicked:(id)sender
{
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:LocalizedString(@"Add from...")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    [sheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Web")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        [self addFromWebClicked];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Magnet")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        [self addFromMagnetClicked];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"URL")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        [self addFromURLClicked];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Cancel")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];

    sheet.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)bandwidthButtonClicked:(id)sender
{
    BandwidthController *c = [[BandwidthController alloc] initWithNibName:@"BandwidthController" bundle:nil];
    c.torrent = nil;
    c.controller = self.controller;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:c];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)infoButtonClicked:(id)sender
{
    InfoViewController *viewController = [InfoViewController infoWithPageName:@"about"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)prefButtonClicked:(id)sender
{
    PrefViewController *prefViewController = [[PrefViewController alloc] initWithNibName:@"PrefViewController" bundle:nil];
    prefViewController.controller = self.controller;
    UINavigationController *prefNav = [[UINavigationController alloc] initWithRootViewController:prefViewController];
    [self presentViewController:prefNav animated:YES completion:nil];
}

- (void)controlButtonClicked:(id)sender
{
    CGPoint pos = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pos];
	
	Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
	if ([torrent isActive])
		[torrent stopTransfer];
	else 
		[torrent startTransfer];
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setupCell:(TorrentCell*)cell forTorrent:(Torrent*)t
{
	[t update];

	cell.nameLabel.text = [t name];
	cell.upperDetailLabel.text = [t progressString];

	if (![t isChecking]) {
        [cell.progressView setProgress:[t progress]];
    }
    
	if ([t isSeeding])
		[cell useGreenColor];
	else if ([t isChecking]) {
		[cell useGreenColor];
        [cell.progressView setProgress:[t checkingProgress]];
    }
	else if ([t isActive] && ![t isComplete])
		[cell useBlueColor];
	else if (![t isActive])
		[cell useBlueColor];
	else if (![t isChecking])
		[cell useGreenColor];

	if ([t isActive])
		[cell.controlButton setPauseStyle];
	else 
		[cell.controlButton setResumeStyle];

	if (![self.controller isStartingTransferAllowed]) {
		[cell.controlButton setEnabled:NO];
	}
	else {
		[cell.controlButton setEnabled:YES];
	}

	cell.lowerDetailLabel.text = [t statusString];	
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removedTorrents:) name:NotificationTorrentsRemoved object:self.controller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityCounterDidChange:) name:NotificationActivityCounterChanged object:self.controller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTorrentAdded:) name:NotificationNewTorrentAdded object:self.controller];

    self.activityItemView.backgroundColor = [UIColor clearColor];
    self.activityItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityItemView];
		
	UIButton *_infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[_infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:_infoButton];
	self.navigationItem.rightBarButtonItem = self.infoButton;
	
	self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)];
	
    [self.activityCounterBadge setBadgeColor:[UIColor colorWithRed:0.82 green:0.0 blue:0.082 alpha:1.000]];
}

- (void)resumeButtonClicked:(id)sender
{
	for (NSIndexPath *indexPath in self.selectedIndexPaths) {
		Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
		[torrent startTransfer];
	}

	[self.tableView reloadData];

	self.selectedIndexPaths = nil;	
}

- (void)pauseButtonClicked:(id)sender
{
	for (NSIndexPath *indexPath in self.selectedIndexPaths) {
		Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
		[torrent stopTransfer];
	}

	[self.tableView reloadData];

	self.selectedIndexPaths = nil;
}

- (void)removeButtonClicked:(id)sender
{
	NSString *msg;
	if ([self.selectedIndexPaths count] == 1)
		msg = LocalizedString(@"Are you sure to remove one torrent?");
	else
		msg = [NSString stringWithFormat:LocalizedString(@"Are you sure to remove %lu torrents?"), (unsigned long)[self.selectedIndexPaths count]];

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:msg
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];

    __weak __typeof(self) weakSelf = self;
    [actionSheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Yes and remove data")
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction *action) {
        [weakSelf performRemoveSelected:YES];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Yes but keep data")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
        [weakSelf performRemoveSelected:NO];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Cancel")
                                                    style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction *action) {
        weakSelf.selectedIndexPaths = [NSMutableArray array];
    }]];

    actionSheet.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)editButtonClicked:(id)sender
{
	for (UIBarButtonItem *item in self.editToolbarItems) {
		[item setEnabled:NO];
	}

	[self.tableView setEditing:YES animated:YES];
	[self.navigationItem setLeftBarButtonItem:self.doneButton animated:YES];
	[self setToolbarItems:self.editToolbarItems animated:YES];
	self.selectedIndexPaths = [NSMutableArray array];
}

- (void)doneButtonClicked:(id)sender
{
	[self.tableView setEditing:NO animated:YES];
	[self.navigationItem setLeftBarButtonItem:self.editButton animated:YES];
	[self setToolbarItems:self.normalToolbarItems animated:YES];
	
	for (NSIndexPath *indexPath in self.selectedIndexPaths) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	self.selectedIndexPaths = nil;
}

- (void)updateUI
{
    [super updateUI];

	NSArray *visibleCells = [self.tableView visibleCells];
	
	for (TorrentCell *cell in visibleCells) {
		[self performSelector:@selector(updateCell:) withObject:cell afterDelay:0.0f];
	}
}

- (void)updateCell:(TorrentCell*)c
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:c];
	if (indexPath) {
		Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
		[self setupCell:c forTorrent:torrent];
	}
}

- (void)addFromURLClicked
{
    [self addFromURLWithExistingURL:@"" message:LocalizedString(@"Please enter the existing torrent's URL")];
}

- (void)addFromURLWithExistingURL:(NSString*)url message:(NSString*)msg
{
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:LocalizedString(@"Add from URL")
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [dialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = url;
        textField.placeholder = @"http://";
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = YES;
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = NO;
    }];

    [dialog addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    __weak UIAlertController *weakDialog = dialog;
    [dialog addAction:[UIAlertAction actionWithTitle:LocalizedString(@"OK")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        NSString *enteredURL = weakDialog.textFields.firstObject.text;
        if (![enteredURL hasPrefix:@"http://"] && ![enteredURL hasPrefix:@"https://"])
            [self addFromURLWithExistingURL:enteredURL message:LocalizedString(@"Error: The URL provided is malformed!")];
        else
            [self.controller addTorrentFromURL:enteredURL];
    }]];

    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)addFromMagnetWithExistingMagnet:(NSString*)magnet message:(NSString*)msg
{
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:LocalizedString(@"Add from magnet")
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [dialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = magnet;
        textField.placeholder = @"magnet:";
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = YES;
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = NO;
    }];

    [dialog addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    __weak UIAlertController *weakDialog = dialog;
    [dialog addAction:[UIAlertAction actionWithTitle:LocalizedString(@"OK")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        NSString *enteredMagnet = weakDialog.textFields.firstObject.text;
        NSError *error = [self.controller addTorrentFromMagnet:enteredMagnet];
        if (error)
            [self addFromMagnetWithExistingMagnet:enteredMagnet message:[error localizedDescription]];
    }]];

    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)activityCounterDidChange:(NSNotification*)notif
{
    NSInteger num = self.controller.activityCounter;
    if (num > 0) {
		self.navigationItem.rightBarButtonItem = self.activityItem;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        [self.activityCounterBadge setHidden:NO];
        [self.activityCounterBadge setBadgeNumber:[NSString stringWithFormat:@"%li", (long)num]];
        [self.activityCounterBadge setNeedsDisplay];
    }
    else if (num == 0) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        [self.activityCounterBadge setHidden:YES];
		self.navigationItem.rightBarButtonItem = self.infoButton;
    }
}

- (void)newTorrentAdded:(NSNotification*)notif
{
    [self.tableView reloadData];
}

- (void)removedTorrents:(NSNotification*)notif
{
	[self.tableView reloadData];
}


- (void)addFromMagnetClicked
{
    [self addFromMagnetWithExistingMagnet:@"" message:LocalizedString(@"Please enter the magnet link below.")];
}

- (void)addFromWebClicked
{
    NSString *URL = @"https://google.com";
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:URL :self.controller :self.navigationController];
	[self.navigationController pushViewController:webViewController animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)performRemoveSelected:(BOOL)trashData
{
    [self.tableView setUserInteractionEnabled:NO];
    [self.UIUpdateTimer invalidate];

    __weak __typeof(self) weakSelf = self;

    [self performBlockOnMainQueue:^{
        NSMutableArray *torrents = [NSMutableArray arrayWithCapacity:[weakSelf.selectedIndexPaths count]];
        for (NSIndexPath *indexPath in weakSelf.selectedIndexPaths) {
            Torrent *t = [weakSelf.controller torrentAtIndex:indexPath.row];
            [torrents addObject:t];
        }
        [weakSelf.controller removeTorrents:torrents trashData:trashData];
        torrents = nil;

        weakSelf.selectedIndexPaths = [NSMutableArray array];

        [weakSelf performBlockOnMainQueue:^{
            [weakSelf.tableView reloadData];
            weakSelf.UIUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakSelf selector:@selector(updateUI) userInfo:nil repeats:YES];
            [weakSelf updateUI];
            [weakSelf.tableView setUserInteractionEnabled:YES];
        } afterDelay:0.25f];
    } afterDelay:0.25f];
}

@end
