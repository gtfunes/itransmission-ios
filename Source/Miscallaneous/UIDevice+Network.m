//
//  UIDevice+Network.m
//  WebServer
//
//  Created by Gaston Funes on 11/28/12.
//  Copyright (c) 2012 Gaston Funes. All rights reserved.
//

#import "UIDevice+Network.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#include <unistd.h>

@implementation UIDevice (Network)

+ (NSString *)getStringFromAddress:(const struct sockaddr *)address {
	if (address && address->sa_family == AF_INET) {
		const struct sockaddr_in* sin = (struct sockaddr_in*) address;
		return [NSString stringWithFormat:@"%@:%d", [NSString stringWithUTF8String:inet_ntoa(sin->sin_addr)], ntohs(sin->sin_port)];
	}
	
	return nil;
}

+ (BOOL)getAddressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address {
	if (!IPAddress || ![IPAddress length]) {
		return NO;
	}
	
	memset((char *) address, sizeof(struct sockaddr_in), 0);
	address->sin_family = AF_INET;
	address->sin_len = sizeof(struct sockaddr_in);
	
	int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
	if (conversionResult == 0) {
		return NO;
	}
	
	return YES;
}

+ (NSString *)getDeviceHostName {
	char baseHostName[256]; 
	int success = gethostname(baseHostName, 255);
	
    if (success != 0) return nil;
	
    baseHostName[255] = '\0';
	
    #if !TARGET_IPHONE_SIMULATOR
        return [NSString stringWithFormat:@"%s.local", baseHostName];
    #else
        return [NSString stringWithFormat:@"%s", baseHostName];
    #endif
}

+ (NSString *)getIPAddressForHost:(NSString *)theHost {
	struct hostent *host = gethostbyname([theHost UTF8String]);
    
    if (!host) { herror("resolv"); return nil; }
	
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
	NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
	
    return addressString;
}

+ (NSString *)getLocalIPAddress {
	struct hostent *host = gethostbyname([[self getDeviceHostName] UTF8String]);
    
    if (!host) { herror("resolv"); return nil; }
    
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
	
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
}

+ (NSString *)getLocalWiFiIPAddress {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

+ (NSString *)getAbsoluteLocalIPAddress {
    #if !TARGET_IPHONE_SIMULATOR
        return [UIDevice getLocalWiFiIPAddress];
    #else
        return [UIDevice getLocalIPAddress];
    #endif
}

@end
