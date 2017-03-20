//
//  UIImageView+TravelKitUI.h
//  SygicTravel-Demo
//
//  Created by Michal Zelinka on 14/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TravelKit/TravelKit.h>


@interface UIFont (TravelKit)

+ (UIFont *)lightSystemFontOfSize:(CGFloat)size;

@end


@interface UIColor (Utils)

+ (UIColor *)colorFromRGB:(int)rgbValue;
+ (UIColor *)colorFromRGB:(int)rgbValue alpha:(CGFloat)alpha;

@end


@interface UIView (TravelKit)

@property (nonatomic) CGFloat width, height;
@property (nonatomic) CGFloat top, left, bottom, right;
@property (nonatomic) CGFloat fromRightEdge, fromBottomEdge;

- (void)addCenteredSubview:(UIView *)view;

@end


@interface UILabel (TravelKit)

- (CGSize)inlineSizeOfText;
- (CGSize)expandedSizeOfText;
- (CGFloat)heightForNumberOfLines:(NSInteger)lines;
- (NSInteger)displayableLines;

@end


@interface UIImageView (TravelKit)

- (void)setImageWithMediumImage:(TKMedium *)medium size:(CGSize)size completion:(void (^)(UIImage *))completion;

@end
