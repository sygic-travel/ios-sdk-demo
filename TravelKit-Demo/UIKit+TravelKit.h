//
//  UIImageView+TravelKitUI.h
//  TravelKit Demo
//
//  Created by Michal Zelinka on 14/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TravelKit/TravelKit.h>


@interface UIDevice (TravelKit)

- (BOOL)canPerformPhoneCall;
- (BOOL)canComposeEmail;

@end


@interface UIFont (TravelKit)

+ (UIFont *)lightSystemFontOfSize:(CGFloat)size;

@end


@interface UIColor (Utils)

+ (UIColor *)colorFromRGB:(NSUInteger)rgbValue;
+ (UIColor *)colorFromRGB:(NSUInteger)rgbValue alpha:(CGFloat)alpha;

@end


@interface UIImage (TravelKit)

+ (UIImage *)templateImageNamed:(NSString *)imageName;
+ (UIImage *)blankImageWithSize:(CGSize)size;

@end


@interface UIView (TravelKit)

@property (nonatomic) CGFloat width, height;
@property (nonatomic) CGFloat top, left, bottom, right;
@property (nonatomic) CGFloat fromRightEdge, fromBottomEdge;

- (void)addCenteredSubview:(UIView *)view;

- (NSArray *)viewsForClass:(Class)className;

@end


@interface UIBarButtonItem (TravelKit)

+ (instancetype)emptyBarButtonItem;
+ (instancetype)closeBarButtonItemWithTarget:(id)target selector:(SEL)selector;

@end


@interface UILabel (TravelKit)

- (CGSize)inlineSizeOfText;
- (CGSize)expandedSizeOfText;
- (CGFloat)heightForNumberOfLines:(NSInteger)lines;
- (NSInteger)displayableLines;

@end


@interface UIImageView (TravelKit)

- (void)setImageWithURL:(NSURL *)URL completion:(void (^)(UIImage *))completion;
- (void)setImageWithMediumImage:(TKMedium *)medium size:(CGSize)size completion:(void (^)(UIImage *))completion;

@end
