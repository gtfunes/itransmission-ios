//
//  TackersController.h
//  iTransmission
//
//  Created by Dhruvit Raithatha on 16/12/13.
//
//

#import <Foundation/Foundation.h>
#import "StatisticsViewController.h"

@class Torrent;
@class PeerCell;

@interface PeersViewController : StatisticsViewController <UITableViewDataSource, UITableViewDelegate> {
    __weak Torrent *fTorrent;
    UITableView *fTableView;
    NSMutableArray *Peers;
}
@property (nonatomic, weak, readonly) Torrent *torrent;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id)initWithTorrent:(Torrent*)t;

- (void)updateCell:(PeerCell*)cell;

- (void)reloadPeers;

@end
