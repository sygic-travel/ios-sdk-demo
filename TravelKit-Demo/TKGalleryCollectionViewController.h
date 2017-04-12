//
//  TKGalleryCollectionViewController.h
//  Travel
//
//  Created by Marek Stana on 10/25/16.
//  Copyright © 2016 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TravelKit/TravelKit.h>

#import "TKPlaceImageView.h"


@interface TKGalleryCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TKPlaceImageView *imageView;

- (void)setImageForMedium:(TKMedium *)medium;

@end


@interface TKGalleryCollectionViewController : UIViewController

@property (nonatomic, strong) UICollectionView *collectionView;

- (instancetype)initWithPlace:(TKPlace *)place media:(NSArray<TKMedium *> *)media;

@end
