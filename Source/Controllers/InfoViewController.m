//
//  InfoViewController.m
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 iTransmission authors.
//  SPDX-License-Identifier: GPL-3.0-or-later
//

#import "InfoViewController.h"
#import <WebKit/WebKit.h>

#import "event2/event-config.h"

@implementation InfoViewController
@synthesize pageName;
@synthesize activityIndicator;

+ (id)infoWithPageName:(NSString*)p
{
    return [[InfoViewController alloc] initWithPageName:p];
}

- (id)initWithPageName:(NSString*)p
{
    if ((self = [super init])) {
        self.pageName = p;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    WKWebView *view = [[WKWebView alloc] init];
    view.navigationDelegate = self;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    [self.activityIndicator sizeToFit];
    [self.activityIndicator setHidesWhenStopped:YES];
    self.activityIndicator.autoresizingMask =
    (UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleTopMargin |
     UIViewAutoresizingFlexibleBottomMargin);
    
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] 
                                    initWithCustomView:self.activityIndicator];
    loadingView.target = self;
    self.navigationItem.rightBarButtonItem = loadingView;
    
    NSString *pagePath = [[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Info"] stringByAppendingPathComponent:self.pageName] stringByAppendingPathExtension:@"html"];
    
    self.pageName = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:pagePath] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5.0f];
    [(WKWebView *)self.view loadRequest:request];
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (![[[navigationAction.request URL] scheme] isEqualToString:@"file"]) {
        [[UIApplication sharedApplication] openURL:[navigationAction.request URL]
                                           options:@{}
                                 completionHandler:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    [self.activityIndicator startAnimating];
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    __weak __typeof(self) weakSelf = self;

    [webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error) {
        if ([result isKindOfClass:[NSString class]])
            weakSelf.title = result;
    }];

    if ([[[webView.URL absoluteString] lastPathComponent] isEqualToString:@"about.html"]) {
        NSString *viTrans = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        [webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('itransmission_version').innerHTML = '%@'", viTrans] completionHandler:nil];
        [webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('libtransmission_version').innerHTML = '%s'", LONG_VERSION_STRING] completionHandler:nil];
        [webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('libevent_version').innerHTML = '%s'", _EVENT_VERSION] completionHandler:nil];
    }

    [self.activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    DDLogDebug(@"%@", [error description]);
    [self.activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    DDLogDebug(@"%@", [error description]);
    [self.activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

@end
