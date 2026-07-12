//
//  WebHelper-FileService.h
//  BAT
//
//  Created by Gaston Funes on 7/7/12.
//  Copyright 2012 Gaston Funes.
//  SPDX-License-Identifier: GPL-3.0-or-later
//

#import "WebHelper.h"

@interface WebHelperFileService : WebHelper {
    NSString *cwd;
}

@property (retain) NSString *cwd;

- (NSString *)searchDirectoryPath;

@end
