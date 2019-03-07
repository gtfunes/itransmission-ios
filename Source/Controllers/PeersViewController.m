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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:YES animated:YES];
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
    if (cell == nil) {
        cell = [PeerCell cellFromNib];
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

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
