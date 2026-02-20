//
//  TackersController.m
//  iTransmission
//
//  Created by Dhruvit Raithatha on 16/12/13.
//
//

#import "TrackersViewController.h"
#import "TrackerCell.h"
#import "Torrent.h"
#import "TrackerNode.h"
#import "NSString+Additions.h"
// UIAlertViewPrivate.h removed — UIAlertController provides text fields natively

// ADD_FROM_URL removed — UIAlertController uses inline action blocks instead of delegate tags.
#define ADD_TRACKER_BUTTON 1002
#define REMOVE_TRACKER_BUTTON 1003

@implementation TrackersViewController

- (id)initWithTorrent:(Torrent*)t {
    self = [super initWithNibName:@"TrackersViewController" bundle:nil];
    if (self) {
        fTorrent = t;
        self.title = LocalizedString(@"Trackers");
        SelectedItems = [[NSMutableArray alloc] init];
        Trackers = [[NSMutableArray alloc] init];
        [self reloadTrackers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonTouched)];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouched)];
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeButtonTouched)];
    UIBarButtonItem *emptyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(addButtonTouched)];
    [addButton setTag:ADD_TRACKER_BUTTON];
    [removeButton setTag:REMOVE_TRACKER_BUTTON];
    [addButton setEnabled:NO];
    [removeButton setEnabled:NO];
    [self setToolbarItems:[NSArray arrayWithObjects:emptyButton, addButton, emptyButton, removeButton, emptyButton, nil]];

    // Empty state background view (frame-managed by UITableView; inner stack uses Auto Layout)
    UIView *emptyView = [[UIView alloc] init];

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"antenna.radiowaves.left.and.right"]];
    iconView.tintColor = [UIColor systemGrayColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [NSLayoutConstraint activateConstraints:@[
        [iconView.widthAnchor constraintEqualToConstant:80.0f],
        [iconView.heightAnchor constraintEqualToConstant:80.0f],
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = LocalizedString(@"No Trackers");
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = LocalizedString(@"Add a tracker URL using the + button");
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

- (void)reloadTrackers {
    [Trackers removeAllObjects];

    for (id object in [fTorrent allTrackerStats]) {
        if ([object isKindOfClass:[TrackerNode class]]) {
            if (object != nil) {
                [Trackers addObject:object];
            }
        }
    }

    [self updateEmptyState];
}

- (void)updateEmptyState {
    BOOL isEmpty = ([Trackers count] == 0);
    self.tableView.backgroundView.hidden = !isEmpty;
    self.tableView.separatorStyle = isEmpty ? UITableViewCellSeparatorStyleNone
                                            : UITableViewCellSeparatorStyleSingleLine;
}

- (void)addButtonTouched {
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:LocalizedString(@"Add Tracker")
                                                                    message:LocalizedString(@"Enter the full tracker URL")
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [dialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = LocalizedString(@"Enter tracker URL");
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

    __weak __typeof(self) weakSelf = self;
    __weak UIAlertController *weakDialog = dialog;
    [dialog addAction:[UIAlertAction actionWithTitle:LocalizedString(@"OK")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        // Promote weak refs to strong so ivar access is safe for the duration of this block
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        NSString *url = weakDialog.textFields.firstObject.text;

        // Check for duplicate tracker using proper string comparison
        BOOL exists = NO;
        for (TrackerNode *node in strongSelf->Trackers) {
            if ([[node fullAnnounceAddress] isEqualToString:url]) {
                exists = YES;
                break;
            }
        }

        BOOL validPrefix = ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"] || [url hasPrefix:@"udp://"]);

        if (!validPrefix || exists) {
            NSString *errorMsg = exists
                ? LocalizedString(@"A tracker with the same URL already exists, so both of them are the same trackers.")
                : LocalizedString(@"The URL you entered is invalid. Just where did you get it?");

            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:LocalizedString(@"Error")
                                                                                message:errorMsg
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            [errorAlert addAction:[UIAlertAction actionWithTitle:LocalizedString(@"Dismiss")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil]];
            [strongSelf presentViewController:errorAlert animated:YES completion:nil];
        } else {
            [strongSelf->fTorrent addTrackerToNewTier:url];

            [strongSelf reloadTrackers];
            [strongSelf.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationLeft];
            [strongSelf.tableView reloadData];
        }
    }]];

    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)removeButtonTouched {
    for (TrackerCell *cell in SelectedItems) {
        [fTorrent removeTrackers:[NSSet setWithObject: [[cell TrackerURL] text]]];
    }

    [SelectedItems removeAllObjects];

    [self reloadTrackers];

    [self.tableView reloadData];
}
- (void)editButtonTouched {
    for (UIBarButtonItem *item in self.toolbarItems) {
        if (item.tag == ADD_TRACKER_BUTTON) {
            [item setEnabled:YES];
        }
    }

    [self.tableView setEditing:YES animated:YES];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonTouched)];

    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
}

- (void)doneButtonTouched {
    for (UIBarButtonItem *item in self.toolbarItems) {
        [item setEnabled:NO];
    }

    [self.tableView setEditing:NO animated:YES];

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(editButtonTouched)];

    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TrackerCell *cell = (TrackerCell*)[tableView cellForRowAtIndexPath:indexPath];

    if (tableView.editing == NO) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            UIAlertController *infoAlert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:cell.TrackerLastAnnounceTime.text
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            [infoAlert addAction:[UIAlertAction actionWithTitle:LocalizedString(@"OK")
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil]];
            [self presentViewController:infoAlert animated:YES completion:nil];
        }
    } else {
        for (UIBarButtonItem *item in self.toolbarItems) {
            if (item.tag == REMOVE_TRACKER_BUTTON) {
                [item setEnabled:YES];
            }
        }

        [SelectedItems addObject:cell];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    TrackerCell *cell = (TrackerCell*)[tableView cellForRowAtIndexPath:indexPath];

    if ([SelectedItems containsObject:cell]) {
        [SelectedItems removeObject:cell];
    }

    if ([SelectedItems count] == 0) {
        for (UIBarButtonItem *item in self.toolbarItems) {
            if (item.tag == REMOVE_TRACKER_BUTTON) {
                [item setEnabled:NO];
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [Trackers count];
            break;
        default:
            break;
    }
    return 0;
}

- (void)updateCell:(TrackerCell *)cell {
    if (cell == nil) {
        return;
    }

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    // Cell may no longer be in the table (e.g. deleted while the delayed call was pending)
    if (!indexPath || indexPath.row >= (NSInteger)[Trackers count]) {
        return;
    }

    TrackerNode *node = [Trackers objectAtIndex:indexPath.row];
    
    cell.TrackerURL.text = node.fullAnnounceAddress;
    
    cell.TrackerLastAnnounceTime.text = node.lastAnnounceStatusString;
    
    if (!([node totalSeeders]) || [node totalSeeders] == -1) {
        cell.SeedNumber.text = @"0";
    } else {
        cell.SeedNumber.text = [NSString stringWithFormat:@"%ld", (long)[node totalSeeders]];
    }
    
    if (!([node totalLeechers]) || [node totalLeechers] == -1) {
        cell.PeerNumber.text = @"0";
    } else {
        cell.PeerNumber.text = [NSString stringWithFormat:@"%ld", (long)[node totalLeechers]];
    }

    if (![self.tableView isEditing]) {
        NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell*)cell];

        if (path) {
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)updateUI {
    [super updateUI];

    for (TrackerCell *cell in [self.tableView visibleCells]) {
        [self performSelector:@selector(updateCell:) withObject:cell afterDelay:1];
    }

    if (![self.tableView isEditing]) {
        [self.tableView reloadData];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrackerCell *cell = nil;
    
    cell = (TrackerCell*)[tableView dequeueReusableCellWithIdentifier:@"TrackerCell"];
    
    if (cell == nil) {
        cell = [TrackerCell cellFromNib];
    }
    
    TrackerNode *node = [Trackers objectAtIndex:indexPath.row];

    cell.TrackerURL.text = node.fullAnnounceAddress;

    cell.TrackerLastAnnounceTime.text = node.lastAnnounceStatusString;

    if (!([node totalSeeders]) || [node totalSeeders] == -1) {
        cell.SeedNumber.text = @"0";
    } else {
        cell.SeedNumber.text = [NSString stringWithFormat:@"%ld", (long)[node totalSeeders]];
    }

    if (!([node totalLeechers]) || [node totalLeechers] == -1) {
        cell.PeerNumber.text = @"0";
    } else {
        cell.PeerNumber.text = [NSString stringWithFormat:@"%ld", (long)[node totalLeechers]];
    }

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryCheckmark;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0f;
}

@end
