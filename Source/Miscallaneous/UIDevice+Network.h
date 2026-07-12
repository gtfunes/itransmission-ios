//
//  UIDevice+Network.h
//  WebServer
//
//  Created by Gaston Funes on 11/28/12.
//  Copyright (c) 2012 Gaston Funes.
//  SPDX-License-Identifier: GPL-3.0-or-later
//

@interface UIDevice (Network)

+ (NSString *)getDeviceHostName;

+ (NSString *)getLocalIPAddress;
+ (NSString *)getLocalWiFiIPAddress;

+ (NSString *)getAbsoluteLocalIPAddress;

@end
