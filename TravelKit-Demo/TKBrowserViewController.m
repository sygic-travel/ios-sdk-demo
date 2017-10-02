//
//  TKBrowserViewController.m
//  TravelKit Demo
//
//  Created by Michal Zelinka on 21/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "TKBrowserViewController.h"
#import "UIKit+TravelKit.h"


@interface TKBrowserViewController () <WKNavigationDelegate>

@property (nonatomic, strong) NSURL *initialURL;
@property (nonatomic, strong) NSURL *latestURL;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end


@implementation TKBrowserViewController

- (instancetype)initWithURL:(NSURL *)URL
{
	if (self = [super init])
	{
		_initialURL = URL;
	}

	return self;
}

- (void)loadView
{
	[super loadView];

	self.title = _fixedTitle;
	self.view.backgroundColor = [UIColor whiteColor];

	_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];

	if (self.navigationController.viewControllers.firstObject == self)
		self.navigationItem.leftBarButtonItem = [UIBarButtonItem
			closeBarButtonItemWithTarget:self selector:@selector(closeButtonTapped:)];

	_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
	_statusLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
	_statusLabel.numberOfLines = 0;
	_statusLabel.textAlignment = NSTextAlignmentCenter;
	_statusLabel.textColor = [UIColor colorWithWhite:.8 alpha:1];
	_statusLabel.font = [UIFont systemFontOfSize:16];
	[self.view addCenteredSubview:_statusLabel];

	_webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
	_webView.navigationDelegate = self;
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_webView];

	[_webView loadRequest:[NSURLRequest requestWithURL:_initialURL]];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

//	CGFloat inset = 0;
//	if (self.navigationController) inset +=
//		self.navigationController.navigationBar.top +
//			self.navigationController.navigationBar.height;
//
//	_webView.scrollView.contentInset =
//		_webView.scrollView.scrollIndicatorInsets =
//			UIEdgeInsetsMake(inset, 0, 0, 0);
}


#pragma mark -
#pragma mark Actions


- (void)handleNavigationFailure
{
	_webView.hidden = YES;

	_statusLabel.text = NSLocalizedString(@"Failed to load address \"%@\".", @"TravelKit UI - Browser error format");
	_statusLabel.text = [NSString stringWithFormat:_statusLabel.text, _latestURL.absoluteString];
}

- (IBAction)closeButtonTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark WebKit view delegate


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
	_activityIndicator.alpha = 1.0;
	[_activityIndicator startAnimating];

	_latestURL = webView.URL;

	if (!_fixedTitle)
		self.title = webView.URL.host;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
	[self handleNavigationFailure];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
	[self handleNavigationFailure];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
	_activityIndicator.alpha = 0.0;
	[_activityIndicator stopAnimating];

	if (_fixedTitle) return;

	self.title = webView.title;
}

- (void)dealloc
{
	_webView.navigationDelegate = nil;
	[_webView stopLoading];
}



@end
