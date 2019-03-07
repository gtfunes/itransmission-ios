//
//  UIAlertView+CompletionHandler.m
//  UIAlertView+CompletionHandler
//
//  Created by Spencer MacDonald on 02/09/2011.
//  Copyright 2011 Square Bracket Software. All rights reserved.
//

#import "UIAlertView+CompletionHandler.h"
#import <objc/runtime.h>

NSString * const MCSMUIAlertViewCompletionHandlerKey = @"MCSMUIAlertViewCompletionHandlerKey";

@implementation UIAlertView (CompletionHandler)

- (MCSMUIAlertViewCompletionHandler)completionHandler {
    MCSMUIAlertViewCompletionHandler handler = (MCSMUIAlertViewCompletionHandler)objc_getAssociatedObject(self, (__bridge const void *)(MCSMUIAlertViewCompletionHandlerKey));
    return handler;
}

- (void)setCompletionHandler:(MCSMUIAlertViewCompletionHandler)handler {
    self.delegate = (id<UIAlertViewDelegate>)self;
    
    objc_setAssociatedObject(self, (__bridge const void *)(MCSMUIAlertViewCompletionHandlerKey), handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {    
    MCSMUIAlertViewCompletionHandler handler = (MCSMUIAlertViewCompletionHandler)objc_getAssociatedObject(self, (__bridge const void *)(MCSMUIAlertViewCompletionHandlerKey));
    
    if (handler) {
        handler(buttonIndex);
    }
    
    objc_setAssociatedObject(self, (__bridge const void *)(MCSMUIAlertViewCompletionHandlerKey), nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
