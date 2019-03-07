//
//  WebHelper.m
//  BAT
//
//  Created by Gaston Funes on 7/7/12.
//  Copyright 2012 Gaston Funes. All rights reserved.
//

#import "WebHelper.h"
#include <unistd.h>
#include <arpa/inet.h>
#include <netdb.h>

#define DO_CALLBACK(X, Y) if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(X)]) [sharedInstance.delegate performSelector:@selector(X) withObject:Y];

@implementation WebHelper

@synthesize isServing;
@synthesize delegate;
@synthesize chosenPort;

static WebHelper *sharedInstance = nil;

+ (WebHelper *)sharedInstance {
	if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (id)init {
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillHibernateToBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }

    return self;
}

- (NSString *)getRequest:(int)fd {
	static char buffer[BUFSIZE+1];
	long len = read(fd, buffer, BUFSIZE);
	buffer[len] = '\0';
	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

// Serve files to GET requests
- (void)handleWebRequest:(int)fd {
	// recover request
	NSString *request = [self getRequest:fd];
	
	// Create a category and implement this meaningfully
	NSMutableString *outcontent = [NSMutableString string];
	[outcontent appendString:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
	[outcontent appendString:@"<html><h1>iPhone Developer's Cookbook</h1><h3>Notice</h3>"];
	[outcontent appendString:@"<p>The core WebHelper class is not meant for deployment in its native state.  "];
	[outcontent appendString:@"Please implement a category that adds a response for the following request:</p>"];
	[outcontent appendFormat:@"<pre>%@</pre></html>", request];
	write (fd, [outcontent UTF8String], [outcontent length]);
	close(fd);
}

// Listen for external requests
- (void)listenForRequests {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	static struct sockaddr_in cli_addr; 
	socklen_t length = sizeof(cli_addr);
	
    while (self.isServing) {
        if ((socketfd = accept(listenfd, (struct sockaddr *)&cli_addr, &length)) < 0) {
			self.isServing = NO;
			DO_CALLBACK(serviceWasLost, nil);
		}
		
		[self handleWebRequest:socketfd];
	}
	
	[pool release];
}

// Begin serving data -- this is a private method called by startService
- (BOOL)startServerOnPort:(long)port {
    @try {
        static struct sockaddr_in serv_addr;

        // Set up socket
        if ((listenfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
            self.isServing = NO;
            DO_CALLBACK(serviceCouldNotBeEstablished, nil);
            return NO;
        }

        // Serve on chosen port (or random)
        serv_addr.sin_family = AF_INET;
        serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
        serv_addr.sin_port = HTONS(port);

        // Bind
        if (bind(listenfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
            self.isServing = NO;
            DO_CALLBACK(serviceCouldNotBeEstablished, nil);
            return NO;
        }

        // Find out what port number was chosen.
        int namelen = sizeof(serv_addr);
        if (getsockname(listenfd, (struct sockaddr *)&serv_addr, (void *) &namelen) < 0) {
            close(listenfd);
            self.isServing = NO;
            DO_CALLBACK(serviceCouldNotBeEstablished, nil);
            return NO;
        }

        chosenPort = ntohs(serv_addr.sin_port);

        // Listen
        if (listen(listenfd, 64) < 0) {
            self.isServing = NO;
            DO_CALLBACK(serviceCouldNotBeEstablished, nil);
            return NO;
        }

        self.isServing = YES;

        DO_CALLBACK(serviceWasEstablished, nil);
        
        [NSThread detachNewThreadSelector:@selector(listenForRequests)
                                 toTarget:self 
                               withObject:NULL];
        
        return YES;
    }
    @catch (NSException *exception) {
        if (listenfd) {
            close(listenfd);
        }
        
        self.isServing = NO;
        DO_CALLBACK(serviceCouldNotBeEstablished, nil);

        return NO;
    }
}
- (BOOL)startServer {
    return [self startServerOnPort:0];
}

- (BOOL)startServiceOnPort:(long)port {
    if (self.isServing) return NO;

    return [self startServerOnPort:port];
}
- (BOOL)startService {
    return [self startServiceOnPort:0];
}

- (void)stopService {
    if (self.isServing) {
        self.isServing = NO;

        if (listenfd) {
            close(listenfd);
        }
    }
}

- (void) appWillEnterForeground:(NSNotification*)notification {
    NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];

    if (![fDefaults boolForKey:@"BackgroundDownloading"] || !self.isServing)
    {
        [self startServiceOnPort:([fDefaults integerForKey: @"RPCPort"] + 1)];
    }
}
- (void) appWillHibernateToBackground:(NSNotification*)notification {
    NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];

    if (![fDefaults boolForKey:@"BackgroundDownloading"])
    {
        [self stopService];
    }
}
- (void) appWillTerminate:(NSNotification*)notification {
    [self stopService];
}

- (void)dealloc {
    self.delegate = nil;

    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];

    [super dealloc];
}

@end
