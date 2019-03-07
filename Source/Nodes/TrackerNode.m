/******************************************************************************
 * This file is modified based on TrackerNode.m in Transmission project. 
 * Original copyright declaration is as follows. 
 *****************************************************************************/

/******************************************************************************
 * $Id: TrackerNode.m 10288 2010-02-25 23:06:05Z livings124 $
 *
 * Copyright (c) 2009-2010 Transmission authors and contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *****************************************************************************/

#import "TrackerNode.h"
#import "NSString+Additions.h"

@implementation TrackerNode

- (id) initWithTrackerStat: (tr_tracker_stat *) stat torrent: (Torrent *) torrent
{
    if ((self = [super init]))
    {
        fStat = *stat;
        fTorrent = torrent;
    }
    
    return self;
}

- (NSString *) description
{
    return [@"Tracker: " stringByAppendingString: [self fullAnnounceAddress]];
}

- (id) copyWithZone: (NSZone *) zone
{
    //this object is essentially immutable after initial setup
    return self;
}

- (NSString *) host
{
    return [NSString stringWithUTF8String: fStat.host];
}

- (NSString *) fullAnnounceAddress
{
    return [NSString stringWithUTF8String: fStat.announce];
}

- (NSInteger) tier
{
    return fStat.tier;
}

- (NSUInteger) identifier
{
    return fStat.id;
}

- (Torrent *) torrent
{
    return fTorrent;
}

- (NSInteger) totalSeeders
{
    return fStat.seederCount;
}

- (NSInteger) totalLeechers
{
    return fStat.leecherCount;
}

- (NSInteger) totalDownloaded
{
    return fStat.downloadCount;
}

- (NSString *) lastAnnounceStatusString
{
    NSString * dateString;
    if (fStat.hasAnnounced)
    {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle: NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
                
        dateString = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: fStat.lastAnnounceTime]];
    }
    else
        dateString = LocalizedString(@"N/A");
    
    NSString * baseString;
    if (fStat.hasAnnounced && fStat.lastAnnounceTimedOut)
        baseString = [LocalizedString(@"Announce timed out") stringByAppendingFormat: @": %@", dateString];
    else if (fStat.hasAnnounced && !fStat.lastAnnounceSucceeded)
    {
        baseString = LocalizedString(@"Announce error");
        
        NSString * errorString = [NSString stringWithUTF8String: fStat.lastAnnounceResult];
        if ([errorString isEqualToString: @""])
            baseString = [baseString stringByAppendingFormat: @": %@", dateString];
        else
            baseString = [baseString stringByAppendingFormat: @": %@ - %@", errorString, dateString];
    }
    else
    {
        baseString = [LocalizedString(@"Last Announce") stringByAppendingFormat: @": %@", dateString];
        if (fStat.hasAnnounced && fStat.lastAnnounceSucceeded && fStat.lastAnnouncePeerCount > 0)
        {
            NSString * peerString;
            if (fStat.lastAnnouncePeerCount == 1)
                peerString = LocalizedString(@"got 1 peer");
            else
                peerString = [NSString stringWithFormat: LocalizedString(@"got %d peers"),
                                        fStat.lastAnnouncePeerCount];
            baseString = [baseString stringByAppendingFormat: @" (%@)", peerString];
        }
    }
    
    return baseString;
}

- (NSString *) nextAnnounceStatusString
{
    switch (fStat.announceState)
    {
        case TR_TRACKER_ACTIVE:
            return [LocalizedString(@"Announce in progress") stringByAppendingEllipsis];
        
        case TR_TRACKER_WAITING:
            return [NSString stringWithFormat: LocalizedString(@"Next announce in %@"),
                    [NSString timeString: fStat.nextAnnounceTime - [[NSDate date] timeIntervalSince1970] showSeconds: YES]];
        
        case TR_TRACKER_QUEUED:
            return [LocalizedString(@"Announce is queued") stringByAppendingEllipsis];
        
        case TR_TRACKER_INACTIVE:
            return fStat.isBackup ? LocalizedString(@"Tracker will be used as a backup")
                                    : LocalizedString(@"Announce not scheduled");
        
        default:
            NSAssert1(NO, @"unknown announce state: %d", fStat.announceState);
            return nil;
    }
}

- (NSString *) lastScrapeStatusString
{
    NSString * dateString;
    if (fStat.hasScraped)
    {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle: NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
        
        dateString = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: fStat.lastScrapeTime]];
    }
    else
        dateString = LocalizedString(@"N/A");
    
    NSString * baseString;
    if (fStat.hasScraped && fStat.lastScrapeTimedOut)
        baseString = [LocalizedString(@"Scrape timed out") stringByAppendingFormat: @": %@", dateString];
    else if (fStat.hasScraped && !fStat.lastScrapeSucceeded)
    {
        baseString = LocalizedString(@"Scrape error");
        
        NSString * errorString = [NSString stringWithUTF8String: fStat.lastScrapeResult];
        if ([errorString isEqualToString: @""])
            baseString = [baseString stringByAppendingFormat: @": %@", dateString];
        else
            baseString = [baseString stringByAppendingFormat: @": %@ - %@", errorString, dateString];
    }
    else
        baseString = [LocalizedString(@"Last Scrape") stringByAppendingFormat: @": %@", dateString];
    
    return baseString;
}

@end
