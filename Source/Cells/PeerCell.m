//
//  TrackerCell.m
//  iTransmission
//
//  Created by Dhruvit Raithatha on 02/12/13.
//
//

#import "PeerCell.h"

@implementation PeerCell

@synthesize PeerIP = fIP;
@synthesize PeerClient = fClient;

+ (id)cellFromNib
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PeerCell" owner:nil options:nil];
    PeerCell *cell = (PeerCell*)[objects objectAtIndex:0];
    
    return cell;
}

@end
