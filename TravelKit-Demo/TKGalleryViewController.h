//
//  GalleryViewController.h
//  Tripomatic
//
//  Created by Michal Zelinka on 17/4/2014.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TravelKit/TravelKit.h>

#import "TKGalleryTransitions.h"
#import "TKGalleryMediumView.h"


@interface TKGalleryViewController : UIViewController

- (instancetype)initWithPlace:(TKPlace *)place media:(NSArray<TKMedium *> *)media defaultMedium:(TKMedium *)medium;

@property (nonatomic, copy) NSArray<TKGalleryMediumView *> *mediumViews;

@property (nonatomic, readonly) UIImage *currentImage;
@property (atomic, readonly) NSUInteger currentPage;

@property (atomic) BOOL interactive;
@property (nonatomic, strong) TKGalleryDismissTransition *interactiveTransition;

@end
