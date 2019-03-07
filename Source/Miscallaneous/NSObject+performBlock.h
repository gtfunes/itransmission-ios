//
//  NSObject+performBlock.h
//

#import <Foundation/Foundation.h>

/**
 An NSObject category to perform code blocks in particular threads and with different priorities
 */
@interface NSObject (PerformBlock)

- (void) performBlock:(void(^)(void))block;
- (void) performBlock:(void(^)(void))block afterDelay:(double)delayInSeconds;

- (void) performBlockInBackgroundQueue:(void(^)(void))block;
- (void) performBlockInBackgroundQueue:(void(^)(void))block afterDelay:(double)delayInSeconds;

- (void) performBlockOnMainQueue:(void(^)(void))block;
- (void) performBlockOnMainQueue:(void(^)(void))block afterDelay:(double)delayInSeconds;

- (void) performBlockOnMainQueueWithHighPriority:(void(^)(void))block;
- (void) performBlockOnMainQueueWithHighPriority:(void(^)(void))block afterDelay:(double)delayInSeconds;

@end
