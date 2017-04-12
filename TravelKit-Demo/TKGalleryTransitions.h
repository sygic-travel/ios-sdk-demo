//
//  GalleryTransitions.h
//  Travel
//
//  Created by Marek Stana on 11/9/16.
//  Copyright © 2016 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPlaceImageView.h"


@interface TKGalleryPresentTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) TKPlaceImageView *fromImageView;

@end


@interface TKGalleryDismissTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning>

@property (atomic) CGPoint movedCenterPoint;
@property (atomic) BOOL interactive;
@property (nonatomic, assign) id<UIViewControllerContextTransitioning> context;

@end
