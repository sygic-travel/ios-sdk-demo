//
//  ActivityUserData.h
//  Tripomatic
//
//  Created by Michal Zelinka on 10/12/2014.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityUserData : NSObject

@property (nonatomic, copy) NSString *activityID;
@property (nonatomic, copy) NSString *tripID;
@property (nonatomic, strong) NSNumber *startTime;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, copy) NSString *note;
@property (atomic) NSInteger state;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)asDictionary;

@end
