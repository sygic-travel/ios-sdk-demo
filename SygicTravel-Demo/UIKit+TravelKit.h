//
//  UIImageView+TravelKitUI.h
//  SygicTravel-Demo
//
//  Created by Michal Zelinka on 14/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TravelKit/TravelKit.h>


@interface UIView (TravelKit)

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
