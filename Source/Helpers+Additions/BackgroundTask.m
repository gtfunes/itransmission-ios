//
//  BackgroundTask.m
//  iTransmission
//
//  Created by Gaston Funes on 2/4/15.
//
//

#import "BackgroundTask.h"
#import <AVFoundation/AVFoundation.h>

void interruptionListenerCallback (void *inUserData, UInt32 interruptionState);

@implementation BackgroundTask

@synthesize bgTask = _bgTask;
@synthesize expirationHandler = _expirationHandler;
@synthesize timer = _timer;
@synthesize player = _player;

@synthesize timerInterval = _timerInterval;
@synthesize target = _target;
@synthesize selector = _selector;

-(id) init
{
    if (self = [super init])
    {
        _bgTask = UIBackgroundTaskInvalid;
        _expirationHandler = nil;
        _timer = nil;
    }

    return self;
}

-(void) startBackgroundTaskWithCallbackEvery:(NSInteger)time_ target:(id)target_ selector:(SEL)selector_
{
    _timerInterval = time_;
    _target = target_;
    _selector = selector_;

    [self initBackgroudTask];
    // setKeepAliveTimeout:handler: was deprecated in iOS 9 and is a no-op on
    // all currently supported iOS versions — removed.
}

-(void) initBackgroudTask
{
    if ([self running])
       [self stopAudio];

    while ([self running])
    {
       [NSThread sleepForTimeInterval:10];
    }

    [self playAudio];
}

- (void) audioInterrupted:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSNumber *interuptionType = [interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];

    if ([interuptionType intValue] == AVAudioSessionInterruptionTypeEnded)
    {
        [self initBackgroudTask];
    }

    // Previously this used @selector(selector) — a literal selector named
    // "selector" — which would never match any real method and silently did
    // nothing. Use self.selector (the stored SEL ivar) instead.
    if (self.target && [self.target respondsToSelector:self.selector])
    {
        NSMethodSignature *sig = [self.target methodSignatureForSelector:self.selector];
        if (sig)
        {
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:self.target];
            [inv setSelector:self.selector];
            // Objective-C methods have hidden arguments self and _cmd at indices 0 and 1.
            // The first explicit parameter is at index 2.
            NSNotification *arg = notification;
            if (sig.numberOfArguments > 2)
            {
                [inv setArgument:&arg atIndex:2];
            }
            [inv invoke];
        }
    }
}

- (void) timerFired:(NSTimer *)timer
{
    // BackgroundTask is the NSTimer target (not the external target) to avoid
    // the run loop holding a strong reference to the caller (e.g. Controller).
    // Forward the tick to the external target/selector stored in ivars.
    if (self.target && [self.target respondsToSelector:self.selector])
    {
        NSMethodSignature *sig = [self.target methodSignatureForSelector:self.selector];
        if (sig)
        {
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:self.target];
            [inv setSelector:self.selector];
            // If the selector expects one parameter, pass nil.
            if (sig.numberOfArguments > 2)
            {
                id nilArg = nil;
                [inv setArgument:&nilArg atIndex:2];
            }
            [inv invoke];
        }
    }
}

-(void) playAudio
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];

    __weak __typeof(self) weakSelf = self;

    weakSelf.expirationHandler = ^{
        [[UIApplication sharedApplication] endBackgroundTask:weakSelf.bgTask];
        weakSelf.bgTask = UIBackgroundTaskInvalid;
        [weakSelf.timer invalidate];
        [weakSelf.player stop];
    };
    weakSelf.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:weakSelf.expirationHandler];

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSError *error;
        NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Sound"] stringByAppendingPathComponent:@"background.wav"];

        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
            
            const char bytes[] = {0x52, 0x49, 0x46, 0x46, 0x26, 0x0, 0x0, 0x0, 0x57, 0x41, 0x56, 0x45, 0x66, 0x6d, 0x74, 0x20, 0x10, 0x0, 0x0, 0x0, 0x1, 0x0, 0x1, 0x0, 0x44, 0xac, 0x0, 0x0, 0x88, 0x58, 0x1, 0x0, 0x2, 0x0, 0x10, 0x0, 0x64, 0x61, 0x74, 0x61, 0x2, 0x0, 0x0, 0x0, 0xfc, 0xff};
            NSData* data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
            [data writeToFile:filePath options:NSDataWritingFileProtectionNone error:&error];
        }

        NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];

        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];

        weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        weakSelf.player.volume = 0.01;
        weakSelf.player.numberOfLoops = -1;
        [weakSelf.player prepareToPlay];
        [weakSelf.player play];

        // Use BackgroundTask (weakSelf) as the timer target, NOT weakSelf.target.
        // NSTimer retains its target strongly via the run loop. Passing the
        // external target (e.g. Controller) directly would pin it in memory for
        // as long as the background task runs, and crash if the target is ever
        // released before the timer is invalidated. Instead, BackgroundTask acts
        // as a trampoline: it forwards ticks to the external target in timerFired:.
        if (weakSelf.target && [weakSelf.target respondsToSelector:weakSelf.selector])
        {
            weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:weakSelf.timerInterval
                                                             target:weakSelf
                                                           selector:@selector(timerFired:)
                                                           userInfo:nil
                                                            repeats:YES];
        }
    });
}

-(void) stopAudio
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];

    if (self.timer != nil && [self.timer isValid])
        [self.timer invalidate];

    if (self.player != nil && [self.player isPlaying])
        [self.player stop];

    if (self.bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

-(BOOL) running
{
    return (self.bgTask != UIBackgroundTaskInvalid);
}

-(void) stopBackgroundTask
{
    [self stopAudio];
}

@end

