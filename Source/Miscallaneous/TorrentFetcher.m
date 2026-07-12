//
//  TorrentFetcher.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 iTransmission authors.
//  SPDX-License-Identifier: GPL-3.0-or-later
//

#import "TorrentFetcher.h"

#define FETCH_SIZE_HARD_LIMIT 1024 * 1024 * 3 // 3MB

@implementation TorrentFetcher

@synthesize URLConnection = fDataTask;
@synthesize url;
@synthesize delegate = fDelegate;

- (id)initWithURLString:(NSString*)u delegate:(id<TorrentFetcherDelegate>)d
{
    NSURL *URL = [NSURL URLWithString:u];
    if (!URL) return nil;

    self = [super init];
    if (self) {
        self.url = u;
        self.delegate = d;
        fData = [[NSMutableData alloc] init];

        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                              delegate:self
                                                         delegateQueue:[NSOperationQueue mainQueue]];
        fDataTask = [session dataTaskWithRequest:urlRequest];
        self.URLConnection = fDataTask;
        [fDataTask resume];
    }
    return self;
}

- (BOOL)validateLength:(long long)len
{
    if (len == NSURLResponseUnknownLength) return YES;
    if (len > FETCH_SIZE_HARD_LIMIT) return NO;
    return YES;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    if (![self validateLength:[response expectedContentLength]]) {
        [fDataTask cancel];
        fDataTask = nil;
        NSError *error = [NSError errorWithDomain:@"TorrentFetcher" code:1
                                         userInfo:@{NSLocalizedDescriptionKey: @"File too large"}];
        [self.delegate torrentFetcher:self failedToFetchFromURL:self.url withError:error];
        completionHandler(NSURLSessionResponseCancel);
    } else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [fData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error) {
        [self.delegate torrentFetcher:self failedToFetchFromURL:self.url withError:error];
        fData = nil;
    } else {
        [self.delegate torrentFetcher:self fetchedTorrentContent:fData fromURL:self.url];
        fData = nil;
    }
}

@end
