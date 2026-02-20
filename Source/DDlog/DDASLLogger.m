#import "DDASLLogger.h"

/**
 * Welcome to Cocoa Lumberjack!
 *
 * The project page has a wealth of documentation if you have any questions.
 * https://github.com/CocoaLumberjack/CocoaLumberjack
 *
 * If you're new to the project you may wish to read the "Getting Started" wiki.
 * https://github.com/CocoaLumberjack/CocoaLumberjack/wiki/GettingStarted
**/

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


@implementation DDASLLogger

static DDASLLogger *sharedInstance;

/**
 * The runtime sends initialize to each class in a program exactly one time just before the class,
 * or any class that inherits from it, is sent its first message from within the program. (Thus the
 * method may never be invoked if the class is not used.) The runtime sends the initialize message to
 * classes in a thread-safe manner. Superclasses receive this message before their subclasses.
 *
 * This method may also be called directly (assumably by accident), hence the safety mechanism.
**/
+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;

        sharedInstance = [[[self class] alloc] init];
    }
}

+ (instancetype)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    if (sharedInstance != nil)
    {
        return nil;
    }

    if ((self = [super init]))
    {
        _log = os_log_create("com.apple.console", "default");
    }
    return self;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = logMessage->logMsg;

    if (formatter)
    {
        logMsg = [formatter formatLogMessage:logMessage];
    }

    if (logMsg)
    {
        const char *msg = [logMsg UTF8String];

        os_log_type_t logType;
        switch (logMessage->logFlag)
        {
            case LOG_FLAG_ERROR : logType = OS_LOG_TYPE_FAULT;   break;
            case LOG_FLAG_WARN  : logType = OS_LOG_TYPE_ERROR;   break;
            case LOG_FLAG_INFO  : logType = OS_LOG_TYPE_INFO;    break;
            case LOG_FLAG_DEBUG : logType = OS_LOG_TYPE_DEBUG;   break;
            default             : logType = OS_LOG_TYPE_DEFAULT; break;
        }

        os_log_with_type(_log, logType, "%{public}s", msg);
    }
}

- (NSString *)loggerName
{
    return @"cocoa.lumberjack.aslLogger";
}

@end
