//
//  UIImageView+TravelKitUI.m
//  SygicTravel-Demo
//
//  Created by Michal Zelinka on 14/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import "UIKit+TravelKit.h"


@implementation UILabel (TravelKit)

- (CGSize)expandedSizeOfText
{
	return [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX)];
}

- (CGSize)inlineSizeOfText
{
	return [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame))];
}

- (CGFloat)heightForNumberOfLines:(NSInteger)lines
{
	return MAX(0, lines * ceilf(self.font.lineHeight));
}

- (NSInteger)displayableLines
{
	return MAX(0, floorf(CGRectGetHeight(self.frame) / self.font.lineHeight));
}

@end


@implementation UIImageView (TravelKit)

- (NSOperationQueue *)tk_mediaFetchingQueue
{
	static NSOperationQueue *queue;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		queue = [NSOperationQueue new];
		queue.name = @"TravelKit UI Media fetching queue";
		if ([queue respondsToSelector:@selector(setQualityOfService:)])
			queue.qualityOfService = NSQualityOfServiceUtility;
	});

	return queue;
}

- (NSURLSession *)tk_mediaFetchingSession
{
	static NSURLSession *session;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{

		NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
		config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
		config.timeoutIntervalForResource = 20;
		config.allowsCellularAccess = YES;

		session = [NSURLSession sessionWithConfiguration:config];
		session.delegateQueue.qualityOfService = NSQualityOfServiceUtility;
	});

	return session;
}

- (void)setImageWithMediumImage:(TKMedium *)medium size:(CGSize)size completion:(void (^)(UIImage *))completion
{
	NSString *operationID = [NSString stringWithFormat:@"TKMedium_%@_%.0f_%.0f", medium.ID, size.width, size.height];

	// Cancel previous operation

	for (NSOperation *op in [self tk_mediaFetchingQueue].operations.copy)
		if ([op.name isEqual:operationID])
			[op cancel];

	// Enqueue new one

	NSBlockOperation *op = [NSBlockOperation new];
	__weak NSBlockOperation *wop = op;
	op.name = operationID;
	[op addExecutionBlock:^{

		NSString *sizeString = [NSString stringWithFormat:@"%.0fx%.0f", size.width, size.height];

		NSString *urlString = [medium.previewURL absoluteString];
		urlString = [urlString stringByReplacingOccurrencesOfString:@TKMEDIUM_SIZE_PLACEHOLDER withString:sizeString];

		NSURL *url = [NSURL URLWithString:urlString];

		NSURLSessionDataTask *task = [[self tk_mediaFetchingSession] dataTaskWithURL:url
		completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

			if ([wop isCancelled]) return;

			UIImage *image = nil;
			if (data) image = [UIImage imageWithData:data];

			[self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];

			if (completion) completion(image);
		}];

		[task resume];
	}];

	[[self tk_mediaFetchingQueue] addOperation:op];
}

@end