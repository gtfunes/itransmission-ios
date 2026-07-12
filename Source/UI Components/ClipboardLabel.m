//
//  ClipboardLabel.m
//  iTransmission
//
//  Created by Mike Chen on 10/19/10.
//  Copyright 2010 iTransmission authors.
//  SPDX-License-Identifier: GPL-3.0-or-later
//

#import "ClipboardLabel.h"

@interface ClipboardLabel () <UIEditMenuInteractionDelegate>
@property (nonatomic, strong) UIEditMenuInteraction *editMenuInteraction;
@end

@implementation ClipboardLabel
@synthesize shouldPopUpControlMenu;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		shouldPopUpControlMenu = YES;
		UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
		[self addGestureRecognizer:gr];

        UIEditMenuInteraction *editInteraction = [[UIEditMenuInteraction alloc] initWithDelegate:self];
        [self addInteraction:editInteraction];
        self.editMenuInteraction = editInteraction;
	}
	return self;
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if (CGRectContainsPoint(self.bounds, point))
		return self;
	return [super hitTest:point withEvent:event];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if(action == @selector(copy:)) {
		return YES;
	}
	else {
		return [super canPerformAction:action withSender:sender];
	}
}

- (void)copy:(id)sender {
	UIPasteboard *board = [UIPasteboard generalPasteboard];
	[board setValue:self.text forPasteboardType:@"public.utf8-plain-text"];
	[self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)showMenuFromLocation:(CGPoint)location
{
    if ([self becomeFirstResponder]) {
        UIEditMenuConfiguration *config = [UIEditMenuConfiguration
            configurationWithIdentifier:nil
                            sourcePoint:location];
        [self.editMenuInteraction presentEditMenuWithConfiguration:config];
    }
}

#pragma mark - UIEditMenuInteractionDelegate

- (UIMenu *)editMenuInteraction:(UIEditMenuInteraction *)interaction
                        menuFor:(UIEditMenuConfiguration *)configuration
               suggestedActions:(NSArray<UIMenuElement *> *)suggestedActions
{
    // Return only the Copy action
    UIAction *copyAction = [UIAction actionWithTitle:@"Copy"
                                              image:nil
                                         identifier:nil
                                            handler:^(__kindof UIAction *action) {
        [self copy:nil];
    }];
    return [UIMenu menuWithChildren:@[copyAction]];
}

#pragma mark - Gesture Recognizer

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
		CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
		[self showMenuFromLocation:location];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([[touches anyObject] tapCount] == 2) {
		[self showMenuFromLocation:[[touches anyObject] locationInView:self]];
	}
}

@end
