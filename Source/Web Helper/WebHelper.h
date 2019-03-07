//
//  WebHelper.h
//  BAT
//
//  Created by Gaston Funes on 7/7/12.
//  Copyright 2012 Gaston Funes. All rights reserved.
//

@protocol WebHelperDelegate <NSObject>
@optional
- (void) serviceCouldNotBeEstablished;
- (void) serviceWasEstablished;
- (void) serviceWasLost;
@end

@interface WebHelper : NSObject {
	id <WebHelperDelegate>	delegate;
	
	int				serverStatus;
	BOOL			isServing;
	int				listenfd;
	int				chosenPort;
	int				socketfd;
}

#define BUFSIZE 8096

@property (retain) id delegate;
@property (assign) BOOL isServing;
@property (assign) int chosenPort;

+ (WebHelper *)sharedInstance;

- (BOOL)startServiceOnPort:(long)port;
- (BOOL)startService;
- (void)stopService;

@end
