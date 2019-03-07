//
//  Notifications.h
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NotificationNewTorrentAdded @"NotificationNewTorrentAdded"
#define NotificationActivityCounterChanged @"NotificationActivityCounterChanged"
#define NotificationTorrentsRemoved @"NotificationTorrentsRemoved"
#define NotificationNetworkInterfacesChanged @"NotificationNetworkInterfacesChanged"
#define NotificationGlobalMessage @"NotificationGlobalMessage"
#define NotificationSessionStatusChanged @"NotificationSessionStatusChanged"
#define AudioPrefChanged @"AudioPrefChanged"

#define KeyRemovedTorrents @"KeyRemovedTorrents"
#define KeyActivityCounter @"KeyActivityCounter"

#define TorrentFinishedDownloading @"TorrentFinishedDownloading"
#define TorrentRestartedDownloading @"TorrentRestartedDownloading"
#define TorrentFinishedSeeding @"TorrentFinishedSeeding"
#define TorrentFileCheckChange @"TorrentFileCheckChange"
#define ResetInspector @"ResetInspector"
#define UpdateQueue @"UpdateQueue"
#define UpdateOptions @"UpdateOptions"
#define UpdateStats @"UpdateStats"
