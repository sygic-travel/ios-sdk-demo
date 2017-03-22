//
//  UIImageView+TravelKitUI.m
//  SygicTravel-Demo
//
//  Created by Michal Zelinka on 14/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import "UIKit+TravelKit.h"


#pragma mark -
#pragma mark UIFont
#pragma mark -


@implementation UIFont (TravelKit)

+ (UIFont *)lightSystemFontOfSize:(CGFloat)size
{
	return [UIFont systemFontOfSize:size weight:UIFontWeightLight];
}

@end


#pragma mark -
#pragma mark UIColor
#pragma mark -


@implementation UIColor (Utils)

+ (UIColor *)colorFromRGB:(NSUInteger)rgbValue
{
	return [UIColor colorFromRGB:rgbValue alpha:1.0];
}

+ (UIColor *)colorFromRGB:(NSUInteger)rgbValue alpha:(CGFloat)alpha
{
	return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
						   green:((float)((rgbValue & 0xFF00) >> 8))/255.0
							blue:((float)(rgbValue & 0xFF))/255.0
						   alpha:alpha];
}

@end


#pragma mark -
#pragma mark UIView
#pragma mark -


@implementation UIView (TravelKit)

- (CGFloat)width  { return CGRectGetWidth(self.frame); }
- (CGFloat)height { return CGRectGetHeight(self.frame); }

- (void)setWidth:(CGFloat)width
{
	CGRect f = self.frame;
	f.size.width = width;
	self.frame = f;
}

- (void)setHeight:(CGFloat)height
{
	CGRect f = self.frame;
	f.size.height = height;
	self.frame = f;
}

- (CGFloat)top    { return CGRectGetMinY(self.frame); }
- (CGFloat)left   { return CGRectGetMinX(self.frame); }
- (CGFloat)bottom { return CGRectGetMaxY(self.frame); }
- (CGFloat)right  { return CGRectGetMaxX(self.frame); }

- (void)setTop:(CGFloat)top
{
	CGRect f = self.frame;
	f.origin.y = top;
	self.frame = f;
}

- (void)setLeft:(CGFloat)left
{
	CGRect f = self.frame;
	f.origin.x = left;
	self.frame = f;
}

- (void)setBottom:(CGFloat)bottom
{
	CGRect f = self.frame;
	f.origin.y = bottom - self.height;
	self.frame = f;
}

- (void)setRight:(CGFloat)right
{
	CGRect f = self.frame;
	f.origin.x = right - self.width;
	self.frame = f;
}

- (CGFloat)fromRightEdge
{
	return self.superview.width - self.right;
}

- (CGFloat)fromBottomEdge
{
	return self.superview.height - self.bottom;
}

- (void)setFromRightEdge:(CGFloat)fromRightEdge
{
	CGRect f = self.frame;
	f.origin.x = self.superview.width - fromRightEdge - self.width;
	self.frame = f;
}

- (void)setFromBottomEdge:(CGFloat)fromBottomEdge
{
	CGRect f = self.frame;
	f.origin.y = self.superview.height - fromBottomEdge - self.height;
	self.frame = f;
}

- (void)addCenteredSubview:(UIView *)view
{
	CGRect f = view.frame;
	f.origin.x = (self.width - view.width) / 2.0;
	f.origin.y = (self.height - view.height) / 2.0;
	view.frame = f;

	[self addSubview:view];
}

@end


#pragma mark -
#pragma mark UILabel
#pragma mark -


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


#pragma mark -
#pragma mark UIImageView
#pragma mark -


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
