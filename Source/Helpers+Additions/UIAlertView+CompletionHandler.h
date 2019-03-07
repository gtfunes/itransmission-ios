//
//  UIAlertView+CompletionHandler.h
//  UIAlertView+CompletionHandler
//
//  Created by Spencer MacDonald on 02/09/2011.
//  Copyright 2011 Square Bracket Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MCSMUIAlertViewCompletionHandler)(NSUInteger buttonIndex);

@interface UIAlertView (CompletionHandler)

- (MCSMUIAlertViewCompletionHandler)completionHandler;
- (void)setCompletionHandler:(MCSMUIAlertViewCompletionHandler)handler;

@end