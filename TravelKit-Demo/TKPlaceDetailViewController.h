//
//  TKPlaceDetailViewController.h
//  TravelKit Demo
//
//  Created by Michal Zelinka on 14/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TravelKit/TravelKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKPlaceDetailViewController : UIViewController

@property (nonatomic, strong, readonly) TKPlace *place;
@property (nonatomic, copy, nullable) void (^urlOpeningBlock)(NSURL *URL);

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPlace:(TKPlace *)place;

@end

NS_ASSUME_NONNULL_END
