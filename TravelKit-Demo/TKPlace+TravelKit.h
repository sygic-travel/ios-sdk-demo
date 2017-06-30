//
//  TKPlace+TravelKit.h
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 04/05/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelKit/TravelKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKPlace (TravelKit)

+ (nullable NSString *)localisedNameForCategory:(TKPlaceCategory)category;
- (NSArray<NSString *> *)localisedCategories;

@end

NS_ASSUME_NONNULL_END
