//
//  TKBrowserViewController.h
//  TravelKit Demo
//
//  Created by Michal Zelinka on 21/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKBrowserViewController : UIViewController

@property (nonatomic, copy, nullable) NSString *fixedTitle;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
