//
//  Utils.h
//  Tripomatic
//
//  Created by Michal Zelinka on 8/8/13.
//  Copyright (c) 2013 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>


#pragma mark - UIView auto-resizing mask

#define UtilsViewFlexibleLeftRight (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)
#define UtilsViewFlexibleTopBottom (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)
#define UtilsViewFlexibleMargins (UtilsViewFlexibleLeftRight | UtilsViewFlexibleTopBottom)
#define UtilsViewFlexibleElement (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)

#define UtilsFunctionLineString ([NSString stringWithFormat:@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__])


#pragma mark - NSString

@interface NSString (Utils)

- (NSUInteger)unicodeCharacterLength;
- (NSString *)stringValue;
- (BOOL)isValidURLString;
- (BOOL)isValidEmailString;
- (NSString *)URLEncodedString;
- (NSString *)initialsString;
- (NSString *)trimmedString;
- (BOOL)containsSubstring:(NSString *)str;
- (BOOL)containsSubstring:(NSString *)str ignoreCase:(BOOL)ignoreCase;
- (NSString *)substringToPosition:(NSUInteger)to;
- (NSString *)substringBetweenStarters:(NSArray *)starters andEnding:(NSString *)ending;
+ (NSString *)stringFromLocationCoordinate:(CLLocationCoordinate2D)coordinate;
+ (NSString *)randomStringOfLength:(NSUInteger)length;
- (NSString *)normalizedGUID;

@end


#pragma mark - NSDictionary

typedef NSString *(^NSDictionaryKeyBlock)(id element);

@interface NSDictionary (Utils)

- (NSDictionary *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)nonNullDictionary;
- (NSString *)asJSONString;
+ (NSDictionary *)dictionaryByMappingArray:(NSArray *)array withKeyBlock:(NSDictionaryKeyBlock)block;

@end


#pragma mark - NSArray & NSMutableArray

@interface NSArray (Utils)

- (NSArray *)nonNullArray;
- (NSArray *)reversedArray;
- (id)safeObjectAtIndex:(NSUInteger)index;
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;

@end

@interface NSMutableArray (Utils)

- (void)addUniqueObject:(id)object;
- (void)addUniqueObjectsFromArray:(NSArray *)array;

@end


#pragma mark - CLLocation

@interface CLLocation (Utils)

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

static inline CLLocation *CLLocationMake(CLLocationCoordinate2D coordinate) {
	return [[CLLocation alloc] initWithCoordinate:coordinate];
}


#pragma mark - Colors

@interface Colors : NSObject

+ (UIColor *)selectionWhite;
+ (UIColor *)tripomaticBlue;
+ (UIColor *)orange;
+ (UIColor *)lightOrange;
+ (UIColor *)selectionOrange;
+ (UIColor *)darkOrange;
+ (UIColor *)blue;
+ (UIColor *)lightBlue;
+ (UIColor *)selectionBlue;
+ (UIColor *)overfilledBlue;
+ (UIColor *)darkBlue;
+ (UIColor *)green;
+ (UIColor *)red;
+ (UIColor *)cuteRed;
+ (UIColor *)progressGreen;
+ (UIColor *)headerBlue;
+ (UIColor *)headerGray;
+ (UIColor *)menuGray;
+ (UIColor *)menuSelectedGray;
+ (UIColor *)activityGray;
+ (UIColor *)tableCellSeparatorGray;
+ (UIColor *)tableCellSeparatorDarkGray;
+ (UIColor *)tableCellBackground;
+ (UIColor *)tableCellBackgroundHighlighted;
+ (UIColor *)tableCellBackgroundInvalid;
+ (UIColor *)tableCellTitle;
+ (UIColor *)tableCellSubtitle;
+ (UIColor *)navbarTint;
+ (UIColor *)navbarElementsTint;
+ (UIColor *)navbarTitleTextColor;
+ (UIColor *)navbarButtonTextColor;
+ (UIColor *)navbarButtonTextColorHighlighted;
+ (UIColor *)navbarButtonTextColorDisabled;
+ (UIColor *)inTripColor;
+ (UIColor *)inTripTodayColor;
+ (UIColor *)favouritesColor;

@end


#pragma mark - UIApplication

@interface UIApplication (Utils)

@property (nonatomic) BOOL networkActive;
@property (nonatomic) BOOL idleTimerAsDisabled;
@property (nonatomic, readonly) UIView *statusView;

- (void)setAppearance;
- (void)clearAppearance;
- (void)toggleSlowAnimations;
- (UIViewController *)topMostViewController;
- (void)tryRegisterForRemoteNotifications;

@end


#pragma mark - UIDevice

typedef NS_ENUM(UInt8, UIDeviceKind) {
	UIDeviceKindMobile = 1,
	UIDeviceKindTV = 2,
	UIDeviceKindWatch = 3,
};

typedef NS_ENUM(UInt8, UIDeviceType) {
	UIDeviceTypeIPhone = 1,
	UIDeviceTypeIPad = 2,
	UIDeviceTypeAppleTV = 3,
	UIDeviceTypeAppleWatch = 4,
};

typedef NS_ENUM(NSUInteger, UIDeviceFaceColor) {
	UIDeviceFaceColorUnknown = 0,
	UIDeviceFaceColorBlack,
	UIDeviceFaceColorWhite,
};

typedef NS_ENUM(NSUInteger, UIDeviceBackColor) {
	UIDeviceBackColorUnknown = 0,
	UIDeviceBackColorBlack,
	UIDeviceBackColorGray,
	UIDeviceBackColorSilver,
	UIDeviceBackColorGold,
	UIDeviceBackColorRoseGold,
};

@interface UIDevice (Utils)

@property (atomic, readonly) UIDeviceKind deviceKind;
@property (atomic, readonly) UIDeviceType deviceType;
@property (atomic, readonly) UIDeviceFaceColor faceColor;
@property (nonatomic, readonly, copy) NSString *deviceID;
@property (nonatomic, readonly, copy) NSString *deviceName;
@property (nonatomic, readonly, copy) NSString *modelIdentifier;
@property (nonatomic, readonly, copy) NSString *cellularCountryCode;
@property (nonatomic, readonly, copy) NSString *cellularCarrierName;
@property (nonatomic, readonly, copy) NSString *cellularCarrierDisplayedName;
@property (atomic, readonly) BOOL canPerformPhoneCall;
@property (atomic, readonly) BOOL hasCamera;
@property (atomic, readonly) BOOL isPowerfulDevice;
@property (atomic, readonly) BOOL isSimulator;
@property (atomic, readonly) uint64_t freeSpace;

@end


#pragma mark - UIColor

#define UIColorFromRGB(rgb) ([UIColor colorFromRGB:rgb])
#define UIColorFromRGBA(rgb, a) ([UIColor colorFromRGB:rgb alpha:a])

@interface UIColor (Utils)

+ (UIColor *)colorFromRGB:(int)rgbValue;
+ (UIColor *)colorFromRGB:(int)rgbValue alpha:(CGFloat)alpha;
- (UIColor *)colorAdjustedByWhiteStep:(CGFloat)step;

@end


#pragma mark - UIView

@interface UIView (Utils)

- (id)viewForClass:(Class)className;
- (NSArray *)viewsForClass:(Class)className;
- (UIImage *)snaphotImage;

@end


#pragma mark - UILabel

@interface UILabel (Utils)

- (CGSize)inlineSizeOfText;
- (CGSize)expandedSizeOfText;
- (CGFloat)heightForNumberOfLines:(NSInteger)lines;
- (NSInteger)displayableLines;

@end


#pragma mark - UITableView & UICollectionView

@interface UITableView (Utils)

- (void)scrollToTop;
- (void)scrollToTopAnimated:(BOOL)animated;

@end

@interface UICollectionView (Utils)

- (void)scrollToTop;
- (void)scrollToTopAnimated:(BOOL)animated;

@end


#pragma mark - UIImage

@interface UIImage (Utils)

+ (UIImage *)pixelImageWithColor:(UIColor *)color;
+ (UIImage *)blankImageWithSize:(CGSize)size;
+ (UIImage *)nonCachedImageNamed:(NSString *)imageName;
+ (UIImage *)nonCachedImageNamed:(NSString *)imageName withExtension:(NSString *)extension;
+ (UIImage *)templateImageNamed:(NSString *)imageName;
- (UIImage *)imageWithNormalizedOrientation;
- (UIImage *)imageWithNormalizedOrientationAndSize:(CGSize)size;
- (UIImage *)imageScaledToSize:(CGSize)size;
- (UIImage *)imageTintedWithColor:(UIColor *)color;

@end


#pragma mark - UIImageView

@interface UIImageView (Utils)

- (instancetype)initWithImageNamed:(NSString *)imageName;
+ (instancetype)imageViewWithImageNamed:(NSString *)imageName;
+ (instancetype)imageViewWithTemplateImageNamed:(NSString *)imageName;

@end


#pragma mark - UIButton

@interface UIButton (Utils)

+ (UIButton *)buttonWithImageNamed:(NSString *)imageName;

@end


#pragma mark - UIFont

@interface UIFont (Utils)

+ (UIFont *)systemFontOfSize:(CGFloat)size;
+ (UIFont *)lightSystemFontOfSize:(CGFloat)size;
+ (UIFont *)boldSystemFontOfSize:(CGFloat)size;
+ (UIFont *)preferredFontForTextStyle:(NSString *)style;

- (UIFont *)fontAdjustedByPoints:(CGFloat)points;

@end


#pragma mark - CALayer

@interface CALayer (Utils)

- (void)makeRasterizable;

@end


#pragma mark - Rectangle Progress view

@interface ProgressRectView : UIView

@property (nonatomic) float progress;
@property (nonatomic, strong) UIColor *progressColor;

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end


#pragma mark - Paging view

@class PagingView;

@protocol PagingViewDelegate <NSObject>
@optional
- (void)pagingViewFrameUpdated:(PagingView *)pagingView;

@end

@interface PagingView : UIScrollView

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (atomic) BOOL autoresizesPages;
@property (nonatomic, weak) id<PagingViewDelegate, UIScrollViewDelegate> delegate;

@end


#pragma mark - Table cell

@interface TableCell : UITableViewCell

@property (nonatomic) BOOL invalid;
@property (nonatomic, strong) UIColor *invalidColor;

@end


#pragma mark - Tripomatic window

@interface TripomaticWindow : UIWindow
@end


#pragma mark - Global-scope functions

DISPATCH_EXPORT DISPATCH_NONNULL2 DISPATCH_NOTHROW
void dispatch_after_b(NSTimeInterval after, dispatch_block_t block);

