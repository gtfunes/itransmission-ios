//
//  BackgroundTask.h
//  iTransmission
//
//  Created by Gaston Funes on 2/4/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BackgroundTask : NSObject {
    __block UIBackgroundTaskIdentifier _bgTask;
    __unsafe_unretained __block dispatch_block_t _expirationHandler;
    __block NSTimer *_timer;
    __block AVAudioPlayer *_player;

    NSInteger _timerInterval;
    __unsafe_unretained NSObject *_target;
    SEL _selector;
}

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, assign) dispatch_block_t expirationHandler;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, assign) NSInteger timerInterval;
@property (nonatomic, assign) NSObject *target;
@property (nonatomic, assign) SEL selector;

-(void) startBackgroundTaskWithCallbackEvery:(NSInteger)time_ target:(id)target_ selector:(SEL)selector_;
-(void) stopBackgroundTask;

@end
