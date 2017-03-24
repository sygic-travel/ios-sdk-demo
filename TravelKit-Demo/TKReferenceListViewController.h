//
//  TKReferenceListViewController.h
//  TravelKit Demo
//
//  Created by Michal Zelinka on 22/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TravelKit/TravelKit.h>


@interface TKReferenceListViewController : UIViewController

@property (nonatomic, copy, readonly) NSArray<TKReference *> *references;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithReferences:(NSArray<TKReference *> *)references;

@end
