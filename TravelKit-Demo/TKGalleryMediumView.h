//
//  GalleryMediumView.h
//  Tripomatic
//
//  Created by Michal Zelinka on 17/4/14.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <TravelKit/TravelKit.h>


@interface TKGalleryMediumView : UIView

@property (nonatomic, readonly) UIImage *image;
@property (readonly) CGFloat zoomScale;

- (instancetype)initWithFrame:(CGRect)frame medium:(TKMedium *)medium;

- (void)checkImageDisplay;
- (void)resetImageDisplay;

- (void)playPauseVideo;
- (void)playVideo;

@end
