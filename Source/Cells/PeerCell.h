//
//  TrackerCell.h
//  iTransmission
//
//  Created by Dhruvit Raithatha on 02/12/13.
//
//

#import <UIKit/UIKit.h>

@interface PeerCell : UITableViewCell {
    UILabel *fIP;
    UILabel *fClient;
}

+ (id)cellFromNib;

@property (nonatomic, retain) IBOutlet UILabel *PeerIP;
@property (nonatomic, retain) IBOutlet UILabel *PeerClient;

@end
