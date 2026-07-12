//
//  FileListViewController.m
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 iTransmission authors.
//  SPDX-License-Identifier: GPL-3.0-or-later
//

#import "FileListViewController.h"
#import "FileListCell.h"
#import "Torrent.h"
#import "FileListNode.h"
#import "NSString+Additions.h"
#import "Controller.h"

@implementation FileListViewController
@synthesize torrent = fTorrent;
@synthesize tableView = fTableView;
@synthesize docController = _docController;

- (id)initWithTorrent:(Torrent*)t
{
    self = [super initWithNibName:@"FileListViewController" bundle:nil];
    if (self) {
        fTorrent = t;
        self.title = LocalizedString(@"Files");
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.torrent updateFileStat];

    // Empty state background view (frame-managed by UITableView; inner stack uses Auto Layout)
    UIView *emptyView = [[UIView alloc] init];

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"doc"]];
    iconView.tintColor = [UIColor systemGrayColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [NSLayoutConstraint activateConstraints:@[
        [iconView.widthAnchor constraintEqualToConstant:80.0f],
        [iconView.heightAnchor constraintEqualToConstant:80.0f],
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = LocalizedString(@"No Files");
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = LocalizedString(@"File information is not yet available");
    subtitleLabel.font = [UIFont systemFontOfSize:15.0f];
    subtitleLabel.textColor = [UIColor secondaryLabelColor];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.numberOfLines = 0;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[iconView, titleLabel, subtitleLabel]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 12.0f;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [emptyView addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:emptyView.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:emptyView.centerYAnchor],
        [stack.widthAnchor constraintLessThanOrEqualToAnchor:emptyView.widthAnchor constant:-40.0f],
    ]];

    self.tableView.backgroundView = emptyView;
    [self updateEmptyState];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [[self.torrent flatFileList] count];
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListCell *cell = nil;
    
    cell = (FileListCell*)[tableView dequeueReusableCellWithIdentifier:@"FileListCell"];
    
    if (cell == nil) {
        cell = [FileListCell cellFromNib];
    }
    
    FileListNode *node = [[self.torrent flatFileList] objectAtIndex:indexPath.row];
    cell.filenameLabel.text = node.name;
    cell.sizeLabel.text = [NSString stringForFileSize:node.size];
    cell.progressLabel.text = [NSString percentString:[self.torrent fileProgress:node] longDecimals:NO];
    
    if ([self.torrent canChangeDownloadCheckForFiles:node.indexes]) {
        cell.checkbox.hidden = NO;
        cell.checkbox.checked = [self.torrent checkForFiles:node.indexes] == NSOnState ? YES : NO; 
        cell.checkbox.delegate = self;
        cell.checkbox.backwardReference = cell;
    }
    else {
        cell.checkbox.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListNode *node = [[self.torrent flatFileList] objectAtIndex:indexPath.row];

    if ([self.torrent checkForFiles:node.indexes] == NSOnState) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else {
        cell.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)updateCell:(FileListCell*)c
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:c];

	if (indexPath) {
		FileListNode *node = [[self.torrent flatFileList] objectAtIndex:indexPath.row];
        c.progressLabel.text = [NSString percentString:[self.torrent fileProgress:node] longDecimals:NO];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    FileListNode *node = [[self.torrent flatFileList] objectAtIndex:indexPath.row];
    NSString *p = [[[self.torrent.controller defaultDownloadDir] stringByAppendingPathComponent:[node path]] stringByAppendingPathComponent:[node name]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:p]) {
        self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:p]];
        self.docController.delegate = self;
        FileListCell *cell = (FileListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [self.docController presentOpenInMenuFromRect:CGRectMake(0.0, 0.0, cell.contentView.frame.size.width, 20.0) inView:cell.contentView animated:YES];
    } else {
        if (![self.torrent canChangeDownloadCheckForFiles:node.indexes]) {
            return;
        }
        
        NSInteger state = [self.torrent checkForFiles:node.indexes];
        if (state == NSOnState) {
            state = NSOffState;
        }
        else {
            state = NSOnState;
        }
        
        [self.torrent setFileCheckState:state forIndexes:node.indexes];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)updateEmptyState {
    BOOL isEmpty = ([[self.torrent flatFileList] count] == 0);
    self.tableView.backgroundView.hidden = !isEmpty;
    self.tableView.separatorStyle = isEmpty ? UITableViewCellSeparatorStyleNone
                                            : UITableViewCellSeparatorStyleSingleLine;
}

- (void)updateUI
{
    [super updateUI];

    [self.torrent updateFileStat];

    for (FileListCell *cell in [self.tableView visibleCells]) {
        [self performSelector:@selector(updateCell:) withObject:cell afterDelay:0.0f];
    }

    [self updateEmptyState];
}

- (void)checkbox:(id)checkbox hasChangedState:(BOOL)checked
{
    UITableViewCell *cell = (UITableViewCell*)[checkbox backwardReference];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate methods

- (void) documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	
}

- (void) documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
	return self.navigationController.view;
}

- (CGRect) documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
	return self.view.frame;
}

- (void) documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	
}

@end
