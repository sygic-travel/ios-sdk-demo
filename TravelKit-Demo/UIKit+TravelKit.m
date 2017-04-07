//
//  UIImageView+TravelKitUI.m
//  TravelKit Demo
//
//  Created by Michal Zelinka on 14/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <MessageUI/MessageUI.h>
#import "UIKit+TravelKit.h"


#pragma mark -
#pragma mark UIDevice
#pragma mark -


@implementation UIDevice (TravelKit)

- (BOOL)canPerformPhoneCall
{
	static BOOL can = NO;

	static dispatch_once_t once;
	dispatch_once(&once, ^{

		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
			CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
			CTCarrier *carrier = [netInfo subscriberCellularProvider];
			NSString *mnc = [carrier mobileNetworkCode];
			if (([mnc length] != 0) && (![mnc isEqualToString:@"65535"]))
				can = YES;
		}

	});

	return can;
}

- (BOOL)canComposeEmail
{
//#ifdef TARGET_OS_SIMULATOR
//	return NO;
//#else
	return [MFMailComposeViewController canSendMail];
//#endif
}

@end


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


@implementation UIImage (TravelKit)

+ (UIImage *)templateImageNamed:(NSString *)imageName
{
	return [[UIImage imageNamed:imageName]
	        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)blankImageWithSize:(CGSize)size
{
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
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

- (NSArray *)viewsForClass:(Class)className
{
	NSMutableArray *arr = [NSMutableArray array];
	
	for (UIView *v in self.subviews)
	{
		if ([v isKindOfClass:className])
			[arr addObject:v];

		[arr addObjectsFromArray:[v viewsForClass:className]];
	}

	return arr;
}

@end


#pragma mark -
#pragma mark UIBarButtonItem
#pragma mark -


@implementation UIBarButtonItem (TravelKit)

+ (instancetype)emptyBarButtonItem
{
	return [[self alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

+ (instancetype)closeBarButtonItemWithTarget:(id)target selector:(SEL)selector
{
	return [[UIBarButtonItem alloc] initWithImage:[UIImage templateImageNamed:@"navbar-close"]
		style:UIBarButtonItemStylePlain target:target action:selector];
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

- (void)setImageWithURL:(NSURL *)URL completion:(void (^)(UIImage *))completion
{
	NSString *operationID = [NSString stringWithFormat:@"TKImage_%tu", URL.hash];

	// Cancel previous operation

	for (NSOperation *op in [self tk_mediaFetchingQueue].operations.copy)
		if ([op.name isEqual:operationID])
			[op cancel];

	// Enqueue new one

	NSBlockOperation *op = [NSBlockOperation new];
	__weak NSBlockOperation *wop = op;
	op.name = operationID;
	[op addExecutionBlock:^{

		NSURLSessionDataTask *task = [[self tk_mediaFetchingSession] dataTaskWithURL:URL
		completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

			if ([wop isCancelled]) return;

			UIImage *image = nil;
			if (data) image = [UIImage imageWithData:data];

			[[NSOperationQueue mainQueue] addOperationWithBlock:^{

				self.image = image;
				if (completion) completion(image);


			}];
		}];

		[task resume];
	}];

	[[self tk_mediaFetchingQueue] addOperation:op];
}

- (void)setImageWithMediumImage:(TKMedium *)medium size:(CGSize)size completion:(void (^)(UIImage *))completion
{
	NSString *sizeString = [NSString stringWithFormat:@"%.0fx%.0f", size.width, size.height];

	NSString *urlString = [medium.previewURL absoluteString];
	urlString = [urlString stringByReplacingOccurrencesOfString:@TKMEDIUM_SIZE_PLACEHOLDER withString:sizeString];

	NSURL *url = [NSURL URLWithString:urlString];

	[self setImageWithURL:url completion:completion];
}

@end
