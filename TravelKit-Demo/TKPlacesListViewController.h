//
//  TKPlacesListViewController.h
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 06/04/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TravelKit/TravelKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKPlacesListViewController : UIViewController

@property (nonatomic, strong, readonly) TKPlacesQuery *query;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithQuery:(TKPlacesQuery *)query;

@end

NS_ASSUME_NONNULL_END
