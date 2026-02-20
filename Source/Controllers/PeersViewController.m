//
//  TackersController.m
//  iTransmission
//
//  Created by Dhruvit Raithatha on 16/12/13.
//
//

#import "PeersViewController.h"
#import "Torrent.h"
#import "PeerCell.h"

@implementation PeersViewController

- (id)initWithTorrent:(Torrent*)t {
    self = [super initWithNibName:@"PeersViewController" bundle:nil];
    if (self) {
        fTorrent = t;
        self.title = LocalizedString(@"Peers");
        Peers = [[NSMutableArray alloc] init];
        [self reloadPeers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Empty state background view (frame-managed by UITableView; inner stack uses Auto Layout)
    UIView *emptyView = [[UIView alloc] init];

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"person.2"]];
    iconView.tintColor = [UIColor systemGrayColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [NSLayoutConstraint activateConstraints:@[
        [iconView.widthAnchor constraintEqualToConstant:80.0f],
        [iconView.heightAnchor constraintEqualToConstant:80.0f],
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = LocalizedString(@"No Peers");
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = LocalizedString(@"Peers will appear as the torrent connects");
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)updateEmptyState {
    BOOL isEmpty = ([Peers count] == 0);
    self.tableView.backgroundView.hidden = !isEmpty;
    self.tableView.separatorStyle = isEmpty ? UITableViewCellSeparatorStyleNone
                                            : UITableViewCellSeparatorStyleSingleLine;
}

- (void)reloadPeers {
    [Peers removeAllObjects];
    [Peers addObjectsFromArray:[fTorrent peers]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [Peers count];
            break;
        default:
            break;
    }
    return 0;
}

- (void)updateCell:(PeerCell *)cell {
    if (cell == nil) return;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    // Cell may no longer be in the table (e.g. while a delayed call was pending)
    if (!indexPath || indexPath.row >= (NSInteger)[Peers count]) return;

    NSDictionary *peer = [Peers objectAtIndex:indexPath.row];

    cell.PeerIP.text = [NSString stringWithFormat:@"%@:%d", peer[@"IP"], [peer[@"Port"] intValue]];
    cell.PeerClient.text = peer[@"Client"];
}

- (void)updateUI {
    [super updateUI];

    [self reloadPeers];

    if (![self.tableView isEditing]) {
        [self.tableView reloadData];
    }

    [self updateEmptyState];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PeerCell *cell = nil;

    cell = (PeerCell*)[tableView dequeueReusableCellWithIdentifier:@"PeerCell"];

    if (cell == nil) {
        cell = [PeerCell cellFromNib];
    }

    NSDictionary *peer = [Peers objectAtIndex:indexPath.row];

    cell.PeerIP.text = [NSString stringWithFormat:@"%@:%d", peer[@"IP"], [peer[@"Port"] intValue]];
    cell.PeerClient.text = peer[@"Client"];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 63.0f;
}

@end
