//
//  TKPlaceImageView.h
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 06/04/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKPlaceImageView : UIView

@property (nonatomic, readonly) UIImage *image;

- (void)setImageForMedium:(TKMedium *)medium withSize:(CGSize)size;
- (void)setImageForMedium:(TKMedium *)medium withSize:(CGSize)size completion:(void (^)())completion;

- (void)setImageForPlace:(TKPlace *)place withSize:(CGSize)size;

@end
